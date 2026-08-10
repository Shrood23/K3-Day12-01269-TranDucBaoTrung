# Thông Tin Deploy — Checkpoint 5

Tài liệu này ghi lại bản triển khai cloud của service `day12-agent`. Các giá trị
bí mật chỉ được cấu hình trên Render; repository chỉ ghi tên biến môi trường.

## Thông Tin Học Viên

| Mục | Nội dung |
|-----|----------|
| Họ và tên | Trần Đức Bảo Trung |
| Mã học viên | 2A202601269 |
| Repository | https://github.com/Shrood23/K3-Day12-01269-TranDucBaoTrung |

## Thông Tin Service

| Mục | Nội dung |
|-----|----------|
| Public URL | https://day12-agent-khqe.onrender.com |
| Platform | Render |
| Runtime | Docker |
| Gói dịch vụ | Free |
| Branch deploy | `main` |
| Ngày deploy | 2026-08-10 |

## Biến Môi Trường Trên Cloud

Chỉ liệt kê tên biến và nguồn cấu hình, không lưu giá trị bí mật trong repository.

| Biến | Trạng thái | Nguồn cấu hình |
|------|------------|----------------|
| `PORT` | ✅ | Render tự gán; container đọc biến lúc khởi động |
| `AGENT_API_KEY` | ✅ | Secret nhập trực tiếp trên Render Dashboard |
| `REDIS_URL` | ✅ | Connection string của Render Key Value qua `fromService` |
| `RATE_LIMIT_PER_MINUTE` | ✅ | Khai báo trong `render.yaml` |
| `MONTHLY_BUDGET_USD` | ✅ | Khai báo trong `render.yaml` |
| `LOG_LEVEL` | ✅ | Khai báo trong `render.yaml` |

## Các Bước Deploy Đã Thực Hiện

1. Hoàn thiện và kiểm tra CP1–CP4 bằng môi trường ảo của dự án.
2. Commit code và push branch `main` lên GitHub.
3. Trên Render Dashboard, chọn **New → Blueprint** và kết nối repository.
4. Render đọc `render.yaml`, build `day12-agent` từ `Dockerfile` và tạo
   `day12-redis` dưới dạng Render Key Value.
5. Nhập secret `AGENT_API_KEY` trực tiếp trên Render Dashboard.
6. Chờ health check thành công và lấy public domain HTTPS của web service.

## Lệnh Kiểm Tra

Các lệnh tương đương trên PowerShell:

```powershell
$URL = "https://day12-agent-khqe.onrender.com"

# Liveness
curl.exe -i "$URL/health"

# Readiness và kết nối Redis
curl.exe -i "$URL/ready"

# Không có API key
curl.exe -i -X POST "$URL/ask" `
  -H "Content-Type: application/json" `
  -d '{\"question\":\"Hello\"}'
```

## Kết Quả Chạy Thật

Đã kiểm tra trực tiếp public service ngày 2026-08-10:

| Kiểm tra | Kết quả | Nội dung xác minh |
|----------|---------|-------------------|
| `GET /health` | `200 OK` | `{"status":"ok","service":"day12-agent","version":"1.0.0"}` |
| `GET /ready` | `200 OK` | Service kết nối thành công với Render Key Value |
| `POST /ask` không có API key | `401 Unauthorized` | Endpoint từ chối request chưa xác thực |
| HTTPS | Đạt | Public URL sử dụng chứng chỉ HTTPS của Render |

Kết quả Checkpoint 5:

```text
collected 13 items
8 passed, 5 skipped in 2.35s
```

Năm test bị bỏ qua gồm một kiểm tra xác thực tùy chọn do máy local chưa đặt
`DEPLOY_API_KEY`, cùng bốn kiểm tra chỉ dành cho phương án `LOCAL_FALLBACK`.
Các kiểm tra bắt buộc của bản deploy cloud đều đạt.

## Ảnh Chụp Màn Hình

- [Render Dashboard](screenshots/Screenshot%202026-08-10%20124242.png) — service
  `day12-agent` chạy bằng Docker, gói Free, trạng thái deploy live.
- [Kết quả health check](screenshots/Screenshot%202026-08-10%20124325.png) — trình
  duyệt gọi `/health` và nhận `status: ok`.

## Ghi Chú

- Render Free có thể đưa web service về trạng thái ngủ khi không có traffic;
  request đầu tiên sau thời gian nghỉ có thể phản hồi chậm.
- Dữ liệu Render Key Value gói Free là dữ liệu in-memory và có thể mất khi
  instance khởi động lại; cấu hình này phù hợp cho mục đích lab.
- Không commit file `.env` hoặc bất kỳ giá trị API key nào vào repository.
