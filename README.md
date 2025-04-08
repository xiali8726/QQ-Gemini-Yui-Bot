# 结衣 - 基于 Gemini 的 QQ 机器人

这是一个基于 Python、Flask 和 Google Gemini API 构建的 QQ 聊天机器人。它通过连接到 CQHTTP 兼容的服务（如 go-cqhttp）来接收和发送 QQ 消息。

## 主要特性

*   **智能 AI 对话:**
    *   使用 Google Gemini (默认 `gemini-1.5-pro`, 可配置其他模型) 进行流畅的自然语言对话。
    *   支持上下文感知，能够进行多轮对话。
    *   可配置的系统提示 (`system_prompt`) 来定义机器人的性格和行为 (默认是傲娇猫娘，可配置为写作助手或其他)。
*   **多样的消息处理:**
    *   支持私聊和群聊消息。
    *   群聊中可通过 @机器人 或指定关键词 (`group_keyword`) 触发响应。
    *   自动将过长的消息转换为图片发送（`max_length` 可配置）。
    *   支持将文本回复转换为语音消息发送（`default_send_voice`, `qq_bot.voice` 可配置，需要 TTS 库支持）。
*   **灵活的权限管理:**
    *   内置多级权限系统 (`admin`, `group_manager`, `private_user`, `global_blacklisted` 以及群组黑名单)。
    *   管理员可通过 `权限` 命令管理用户角色。
    *   群管理员可管理其负责群组的特定设置和黑名单（通过 `设置` 命令）。
*   **细粒度配置系统:**
    *   所有配置项存储在 `config.json` 文件中。
    *   支持全局、群组、用户特定配置的分层覆盖逻辑。
    *   可通过 `设置` 命令动态查看和修改部分配置（需要相应权限）。
    *   详细配置说明请参见 `SETTINGS.md`。
*   **丰富的聊天命令:** (需 `enable_chat_commands` 开启)
    *   `帮助`/`help`: 显示可用命令和当前状态。
    *   `语音开启`/`语音关闭`: 切换当前会话语音回复。
    *   (AI 相关，需 `enable_ai_chat` 开启)
        *   `重置会话`: 清空对话历史。
        *   `回滚对话`: 撤销上一轮。
        *   `查看对话`: 显示对话记录。
        *   `刷新对话`: 重新生成上一条回复。
        *   `编辑回复 <新内容>`: 修改上一条 AI 回复。
        *   `修改系统提示词 <提示>`: (需 `enable_personality_retrain` 开启) 修改 AI 核心设定。
    *   `设置 ...`: 查看和修改配置（管理员/群管）。
    *   `权限 ...`: 管理用户角色（管理员）。
*   **随机事件:** (需 `enable_random_events` 开启)
    *   目前包含随机复读 (`enable_repeat_event` 控制)，可配置概率、冷却。
*   **其他功能:**
    *   支持好友请求和群邀请的自动处理 (`auto_confirm` 可配置)。
    *   支持 HTTP API 接口 (`/api/chat`, `/api/reset_chat`) 进行外部交互。
    *   详细的日志记录 (`log` 配置块)。
    *   支持配置 HTTP/HTTPS 代理 (`proxy` 配置块)。
    *   支持 Gemini API Key 轮换使用。
    *   内置消息频率限制 (`message_rate_limit`)。

## 环境要求

*   **Python:** 3.12 或更高版本。
*   **pip:** 用于安装 Python 包。
*   **go-cqhttp 或其他 CQHTTP 兼容服务:** 用于连接 QQ 网络。需要配置反向 WebSocket 或 HTTP POST 连接。
*   **Google Gemini API Key:** 需要一个或多个有效的 API Key。
*   **(可选) 图片和语音依赖:**
    *   文本转图片 (`text_to_image.py`) 可能需要 `Pillow` 库 (`pip install Pillow`)。
    *   文本转语音 (`text_to_speech.py`) 可能需要特定的 TTS SDK，例如 Azure TTS (`pip install azure-cognitiveservices-speech`) 或其他库，具体取决于实现。请检查这两个文件的依赖。

## 安装步骤

1.  **克隆或下载代码:**
    ```bash
    git clone <your-repo-url>
    cd <your-repo-directory>
    ```
2.  **安装核心依赖:** (建议在虚拟环境中进行)
    ```bash
    pip install Flask requests google-generativeai
    ```
3.  **(可选) 安装媒体依赖:**
    ```bash
    # 如果需要文本转图片
    pip install Pillow
    # 如果需要文本转语音 (示例：Azure)
    # pip install azure-cognitiveservices-speech
    # 根据你的 text_to_speech.py 实现安装相应库
    ```
    *   **注意:** 如果你没有 `requirements.txt` 文件，可以根据以上命令创建一个。
4.  **配置 `config.json`:**
    *   **重要:** 本项目提供了一个配置模板文件 `config.template.json`。
    *   **推荐用法:**
        1.  将 `config.template.json` 复制一份并重命名为 `config.json`。
            ```bash
            # 在 Linux / macOS / Git Bash 中:
            cp config.template.json config.json
            # 在 Windows Cmd 中:
            copy config.template.json config.json
            # 在 Windows PowerShell 中:
            Copy-Item config.template.json config.json
            ```
        2.  **编辑** 新创建的 `config.json` 文件。
        3.  **必须** 填入以下**必需项**:
            *   `qq_bot.qq_no`: 你的机器人的 QQ 号 (字符串格式)。
            *   `qq_bot.admin_qq`: 你的管理员 QQ 号 (字符串格式)。
            *   `gemini.api_keys`: 一个包含至少一个有效 Google Gemini API Key 的列表 (字符串列表)。请将 `"REQUIRED_YOUR_GEMINI_API_KEY_HERE"` 替换为真实的 Key。
        4.  根据你的 go-cqhttp 设置，修改 `qq_bot.cqhttp_url`。
        5.  根据需要调整其他配置项。**详细说明请参见 `SETTINGS.md` 文件。**
    *   **注意:** 首次运行时，如果 `config.json` 不存在，程序也会自动根据代码内置的默认值创建一个，但推荐使用模板开始。
    *   **安全警告:** **切勿** 将包含真实 API 密钥或其他敏感信息的 `config.json` 文件提交到公共 Git 仓库！请确保 `config.json` 已被添加到 `.gitignore` 文件中。
5.  **设置 go-cqhttp:**
    *   下载并运行 go-cqhttp。
    *   在 go-cqhttp 的 `config.yml` 文件中，配置**反向** WebSocket 或 HTTP POST 连接，使其指向 QBot 运行的地址和端口（默认为 `http://127.0.0.1:5555/`）。
    *   确保 go-cqhttp 成功登录并运行。
    *   确保 go-cqhttp 配置中的 `data` 目录（或你指定的其他目录）存在，并且 `config.json` 中的 `image_path` 和 `voice_path` 指向 go-cqhttp 可以访问的相应子目录（通常是 `data/images` 和 `data/voices`）。

## 运行机器人

```bash
python QBot_100k.py
```

机器人启动后，会监听指定的端口（默认为 5555）等待来自 go-cqhttp 的事件。日志会输出到控制台和配置的日志文件 (`./logs/app.log`)。

## 使用方法

*   **私聊:** 直接向机器人发送消息 (需要 `private_user` 权限)。
*   **群聊:** (需要在群内未被拉黑)
    *   `@机器人`。
    *   发送包含配置中 `qq_bot.group_keyword` 指定关键词的消息。
*   **命令:** 在私聊或群聊中（如果指向机器人且命令功能开启）发送命令，如 `帮助`, `重置会话` 等。使用 `帮助` 查看当前可用命令。

## 配置

所有配置都在 `config.json` 文件中。该文件支持细粒度的设置，允许为不同群组、用户角色甚至特定用户定义不同的行为。

**请参考 `SETTINGS.md` 获取详细的配置说明。**

## 注意事项

*   请妥善保管你的 Gemini API Key。
*   确保 `config.json` 中的 QQ 号码是正确的字符串格式，特别是 `admin_qq`。
*   修改 `config.json` 后，通常需要重启机器人才能生效（除非使用 `设置 set` 命令动态修改）。
*   如果你使用了 TTS 或 图像生成功能，请确保相关的库已正确安装并且 `config.json` 中的路径设置正确。