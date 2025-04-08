@echo off
setlocal

:: Define a temporary file path (using %TEMP% is standard)
set "TEMP_CLIP_FILE=%TEMP%\clip_temp_%RANDOM%.txt"

:: Write the desired lines to the temporary file
:: '>' creates/overwrites the file with the first line
:: '>>' appends the second line
> "%TEMP_CLIP_FILE%" echo eval $(ssh-agent)
>> "%TEMP_CLIP_FILE%" echo ssh-add ~/.ssh/id_ed25519_xiali8726

:: Use 'type' or '<' to feed the file content to clip
type "%TEMP_CLIP_FILE%" | clip
:: Alternatively: clip < "%TEMP_CLIP_FILE%"

:: Clean up the temporary file
del "%TEMP_CLIP_FILE%"

:: Optional: Display a message
echo Content copied to clipboard. Press any key to exit.
pause

endlocal