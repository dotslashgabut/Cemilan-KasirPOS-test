@echo off
echo ========================================
echo  Run Backend Node.js server
echo ========================================
echo.

if exist "server\" (
    echo Starting Backend Node.js server...
    echo.
    echo URLs:
    echo   Backend:  http://localhost:3001
    echo.
    echo Starting server in new window...
    start "Backend Server" cmd /c "cd server && npm start || echo Server failed to start - possibly database connection error && timeout /t 5"
    echo.
    echo ℹ️  Server is starting in a separate window
    echo    If database connection fails, close. Start Laragon (Apache + MySQL)
    echo.
) else (
    echo Go to server folder and run 'npm start' or 'node index.js'
    echo   Backend:  http://localhost:3001
    echo.
)

echo.
echo Don't forget to:
echo  1. Start Laragon (Apache + MySQL)
echo  2. Import database if not done yet
:: echo  3. Check php_server/.env configuration
echo  3. Run Backend Node.js server
echo.
pause
