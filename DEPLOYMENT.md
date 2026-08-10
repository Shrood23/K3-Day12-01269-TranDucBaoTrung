# Thông Tin Deploy — Checkpoint 5

> Điền file này sau khi deploy xong. `pytest tests/test_cp5.py` đọc file này
> để tìm địa chỉ service của bạn và gọi thử.
>
> **Chỉ ghi TÊN biến môi trường, tuyệt đối không dán giá trị API key vào đây.**
> Repo này công khai — dán khóa vào là mất khóa.

## Thông Tin Học Viên

| Mục | Nội dung |
|-----|----------|
| Họ và tên | Trần Đức Bảo Trung |
| Mã học viên | 01269 |
| Repo | https://github.com/Shrood23/K3-Day12-01269-TranDucBaoTrung |

## Service

| Mục | Nội dung |
|-----|----------|
| Public URL | https://TODO-thay-bang-url-that.up.railway.app |
| Platform | Railway |
| Ngày deploy | 2026-08-10 |

## Biến Môi Trường Đã Set Trên Cloud

Ghi tên biến và **nguồn giá trị**, không ghi giá trị:

| Biến | Đã set | Ghi chú |
|------|--------|---------|
| `PORT` | ✅ | Railway tự gán, app đọc `$PORT` |
| `AGENT_API_KEY` | ✅ | đặt trong dashboard, không nằm trong repo |
| `REDIS_URL` | ✅ | Redis add-on của Railway, tham chiếu `${{Redis.REDIS_URL}}` |
| `RATE_LIMIT_PER_MINUTE` | ✅ | 10 |
| `MONTHLY_BUDGET_USD` | ✅ | 10.0 |
| `LOG_LEVEL` | ✅ | INFO |

## Lệnh Kiểm Tra

Thay `<URL>` bằng Public URL ở trên:

```bash
# 1. Liveness — mong đợi 200 {"status":"ok"}
curl -i <URL>/health

# 2. Readiness — mong đợi 200 {"status":"ready"} (đã nối được Redis)
curl -i <URL>/ready

# 3. Không có API key — mong đợi 401
curl -i -X POST <URL>/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"Hello"}'

# 4. Có API key — mong đợi 200 kèm câu trả lời
curl -i -X POST <URL>/ask \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $AGENT_API_KEY" \
  -H "X-User-Id: sv-test" \
  -d '{"question":"Deploy là gì?"}'

# 5. Rate limit — gọi 15 lần, những lần cuối phải trả 429
for i in $(seq 1 15); do
  curl -s -o /dev/null -w "%{http_code} " -X POST <URL>/ask \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $AGENT_API_KEY" \
    -H "X-User-Id: sv-test" \
    -d '{"question":"test"}'
done; echo
```

Trên PowerShell dùng `curl.exe` thay cho `curl` — `curl` trong PowerShell là
alias của `Invoke-WebRequest` và không hiểu các cờ kiểu Unix như `-i`.

## Các Bước Deploy Đã Thực Hiện

```bash
# 1. Đăng nhập và khởi tạo project
railway login
railway init

# 2. Thêm Redis add-on
railway add --database redis

# 3. Set biến môi trường (KHÔNG commit giá trị vào repo)
railway variables --set AGENT_API_KEY=<khóa-sinh-ngẫu-nhiên>
railway variables --set REDIS_URL='${{Redis.REDIS_URL}}'
railway variables --set RATE_LIMIT_PER_MINUTE=10
railway variables --set MONTHLY_BUDGET_USD=10.0
railway variables --set LOG_LEVEL=INFO

# 4. Deploy — Railway build bằng Dockerfile theo railway.toml
railway up

# 5. Lấy domain công khai
railway domain
```

Sinh khóa mới: `python -c "import secrets; print(secrets.token_urlsafe(32))"`

## Kết Quả Chạy Thật

```
(dán output của 5 lệnh kiểm tra ở trên vào đây sau khi railway up xong)
```

## Ảnh Chụp Màn Hình

Đặt ảnh trong thư mục `screenshots/`:

- `screenshots/dashboard.png` — trang quản lý service trên platform
- `screenshots/health.png` — kết quả gọi `/health` từ trình duyệt hoặc curl
