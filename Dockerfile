# ═══════════════════════════════════════════════════════════════════
# CP2 — Containerization (bản production-ready)
#
#   [x] Multi-stage build: `builder` cài dependency, `runtime` chỉ copy kết quả
#   [x] Base image slim ở cả hai stage
#   [x] COPY requirements.txt + pip install TRƯỚC khi COPY source code
#   [x] Tạo user thường và chuyển sang bằng USER
#   [x] HEALTHCHECK gọi vào /health
#   [x] Đọc cổng từ biến môi trường PORT
#
# Build thử: docker build -t day12-agent:prod .
#            docker images day12-agent:prod     # xem dung lượng
# ═══════════════════════════════════════════════════════════════════

# ── Stage 1: builder — được phép nặng, sẽ bị vứt đi ────────────────
FROM python:3.11-slim AS builder

WORKDIR /app

# Dependency copy riêng và cài TRƯỚC source code: sửa một dòng code
# không làm mất cache layer pip install.
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: runtime — chỉ mang theo KẾT QUẢ, không mang compiler ──
FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

COPY --from=builder /install /usr/local

# Chỉ copy đúng thứ image cần chạy
COPY app ./app
COPY utils ./utils

# Container chạy root nghĩa là thoát được khỏi app là thành root trên host
RUN useradd --create-home --uid 10001 appuser \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:' + os.getenv('PORT', '8000') + '/health').read()" || exit 1

# 0.0.0.0 chứ không phải 127.0.0.1 (bind localhost = bên ngoài container không gọi vào được)
# ${PORT:-8000} vì Railway/Render/Cloud Run tự gán cổng
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
