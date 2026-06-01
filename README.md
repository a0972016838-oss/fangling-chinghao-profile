# Fangling Company Profile Site

這是一個可直接部署到 Vercel 的靜態網站專案。

## 檔案

- `index.html`：首頁
- `fangling.html`：保留原網址路徑使用
- `vercel.json`：Vercel 靜態部署設定
- `package.json`：部署指令設定

## 部署

最簡單的方式是在此資料夾用 PowerShell 執行：

```powershell
.\setup-github-vercel-and-deploy.ps1
```

這會檢查並安裝 Git、GitHub CLI、Node.js 與 Vercel CLI，然後部署到 Vercel 專案：

```text
fangling-chinghao-profile
```

若你已經有工具，只想直接用 Vercel API 部署，也可以執行：

```powershell
.\deploy-to-vercel.ps1
```

## 推上 GitHub

在此資料夾用 PowerShell 執行：

```powershell
.\setup-github-and-push.ps1
```

這會檢查並安裝 Git 與 GitHub CLI，登入 GitHub，建立公開 repository：

```text
fangling-chinghao-profile
```

完成後會顯示 GitHub repository 網址，並存成 `github-url.txt`。
