import wmi
import win32evtlog
import datetime

# تنظیم مسیر فایل خروجی
log_file = "USB_History.txt"

# بازه زمانی (دو ماه گذشته)
start_date = datetime.datetime.now() - datetime.timedelta(days=60)

# تابع برای دریافت اطلاعات دستگاه‌های USB متصل‌شده
def get_usb_devices():
    c = wmi.WMI()
    usb_devices = []
    for device in c.Win32_PnPEntity():
        if device.PNPClass == "USB":
            usb_devices.append(device.Name)
    return usb_devices

# تابع برای دریافت تاریخچه اتصال USB از Event Viewer
def get_usb_event_logs():
    server = "localhost"
    log_type = "System"
    usb_events = []

    # باز کردن لاگ‌های Event Viewer
    hand = win32evtlog.OpenEventLog(server, log_type)
    
    flags = win32evtlog.EVENTLOG_BACKWARDS_READ | win32evtlog.EVENTLOG_SEQUENTIAL_READ
    events = win32evtlog.ReadEventLog(hand, flags, 0)

    while events:   
        for event in events:
            event_time = event.TimeGenerated
            if event_time < start_date:
                return usb_events  # از بازه دو ماه گذشته خارج شدیم
            
            if event.EventID in [2003, 2004]:  # 2003 (وصل شدن) - 2004 (جدا شدن)
                usb_events.append((event.EventID, event.TimeGenerated))
        
        events = win32evtlog.ReadEventLog(hand, flags, 0)

    return usb_events

# دریافت اطلاعات USB و ثبت در فایل
usb_logs = get_usb_event_logs()

with open(log_file, "w", encoding="utf-8") as file:
    file.write("مدل USB | تاریخ و زمان اتصال | مدت زمان اتصال\n")
    file.write("-" * 50 + "\n")

    connected_time = None  # ذخیره زمان وصل شدن برای محاسبه مدت زمان اتصال
    usb_name = "نامشخص"

    for event_id, event_time in usb_logs:
        if event_id == 2003:  # USB متصل شد
            connected_time = event_time
            usb_list = get_usb_devices()
            usb_name = usb_list[0] if usb_list else "نامشخص"
            file.write(f"{usb_name} | {connected_time} | در حال بررسی...\n")
        
        elif event_id == 2004 and connected_time:  # USB جدا شد
            disconnected_time = event_time
            duration = disconnected_time - connected_time
            duration_str = f"{duration.total_seconds() // 3600:.0f} ساعت و {(duration.total_seconds() % 3600) // 60:.0f} دقیقه"
            file.write(f"{usb_name} | {connected_time} | {duration_str}\n")
            connected_time = None  # ریست زمان اتصال برای بررسی بعدی

print(f"Log file created: '{log_file}'")
