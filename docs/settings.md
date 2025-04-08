# 结衣 配置文件详解 (`config.json`)

本文档详细说明了 结衣 使用的 `config.json` 文件结构和所有可配置选项。

## 概述

`config.json` 是 结衣 的核心配置文件，采用 JSON 格式。它包含了机器人的所有设置，从 QQ 连接信息到 AI 模型参数，再到权限和功能开关。

*   **自动创建:** 如果启动时 `config.json` 不存在，机器人会根据内部硬编码的默认值自动创建一个 `config.json` 文件。
*   **JSON 格式:** 请确保文件内容严格遵守 JSON 语法规则。
*   **重启生效:** 大部分配置修改后需要**重启机器人**才能生效。部分设置（如 `settings` 下的部分开关、`random_events` 的概率等）可以通过管理员命令 `/设置 set ...` 动态修改并保存。

## 配置层级与覆盖逻辑

结衣 的配置系统具有分层结构，允许进行非常细粒度的控制。当获取某个配置项时，系统会按照以下优先级顺序查找，找到第一个定义的值即生效：

1.  **用户特定设置 (群组内):** `group.<group_id>.__specific_user__.<user_id>.<key>` (最高优先级)
2.  **用户特定设置 (私聊):** `private.__specific_user__.<user_id>.<key>`
3.  **特定群组内角色设置:** `group.<group_id>.<role>.<key>` (例如 `group.12345.user.settings.enable_ai_chat`)
    *   如果 `<role>` 配置块在 `group.<group_id>` 下不存在，系统会尝试从 `group.__default__.<role>` 复制一份到 `group.<group_id>.<role>`，然后再查找。
4.  **私聊角色默认设置:** `private.__default__.<role>.<key>` (通常只有 `user`)
5.  **全局群组角色默认设置:** `group.__default__.<role>.<key>` (例如 `group.__default__.user.settings.enable_ai_chat`)
6.  **全局顶层设置:** `<key>` (例如 `settings.enable_ai_chat`, `gemini.model`) (最低优先级)

*   `<role>` 通常是 `user`, `manager`, `blacklisted`。
*   如果某个层级没有定义特定配置，系统会自动向上查找，直到找到定义或使用代码中硬编码的最终默认值。
*   **全局开关覆盖:** 某些 `settings.enable_*` 开关（如 `settings.enable_ai_chat`）会作为全局总开关。即使在较低层级（如群组特定设置）中启用了某个功能（如 `enable_ai_chat: true`），如果对应的全局总开关是 `false`，该功能仍然会被禁用。

## 配置项详解

以下是 `config.json` 中主要的配置块及其键值说明 (默认值反映代码中的硬编码默认值):

### 1. `qq_bot` (机器人基础设置)

| 键               | 类型    | 描述                                                                 | 默认值                 | 必需 |
| :--------------- | :------ | :------------------------------------------------------------------- | :--------------------- | :--- |
| `qq_no`          | string  | 机器人的 QQ 号码。                                                     | `"REQUIRED"`           | 是   |
| `admin_qq`       | string  | 管理员的 QQ 号码 (必须是字符串)。                                       | `"REQUIRED"`           | 是   |
| `auto_confirm`   | boolean | 是否自动同意好友请求和群邀请 (请谨慎使用，特别是群邀请)。                   | `false`                | 否   |
| `cqhttp_url`     | string  | go-cqhttp 或兼容服务的反向连接地址 (HTTP POST 或 WebSocket)。          | `"http://127.0.0.1:5700"` | 否   |
| `image_path`     | string  | 用于存放生成的图片文件的路径。go-cqhttp 需要能访问此路径。                  | `"./data/images"`      | 否   |
| `voice_path`     | string  | 用于存放生成的语音文件的路径。go-cqhttp 需要能访问此路径。                  | `"./data/voices"`      | 否   |
| `voice`          | string  | 默认使用的 TTS 语音名称 (例如 Azure TTS 的 `zh-CN-YunxiNeural`)。      | `"zh-CN-YunxiNeural"`  | 否   |
| `max_length`     | integer | 消息长度超过此值时，尝试将文本转为图片发送。                            | `2000`                 | 否   |
| `bot_name`       | string  | 机器人的名字，用于日志、帮助信息等。                                     | `"结衣"`               | 否   |
| `group_keyword`  | string  | 在群聊中触发机器人的关键词 (除了@之外)。设置为 `null` 或空字符串则禁用。 | `"结衣"`               | 否   |

### 2. `gemini` (Google Gemini AI 设置)

| 键                  | 类型    | 描述                                                                                                                                | 默认值                                                                                                                            | 必需 |
| :------------------ | :------ | :---------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------- | :--- |
| `api_keys`          | list    | 包含一个或多个 Google Gemini API Key 的列表 (字符串)。机器人会轮流使用这些 Key。                                                         | `["REQUIRED"]`                                                                                                                    | 是   |
| `model`             | string  | 使用的 Gemini 模型名称。                                                                                                              | `"gemini-1.5-pro"`                                                                                                                | 否   |
| `safety_settings`   | object  | Gemini API 的安全设置。键是 HarmCategory，值是 HarmBlockThreshold。有效值: `BLOCK_NONE`, `BLOCK_ONLY_HIGH`, `BLOCK_MEDIUM_AND_ABOVE`, `BLOCK_LOW_AND_ABOVE`。 | `{"HARM_CATEGORY_HATE_SPEECH": "BLOCK_NONE", "HARM_CATEGORY_SEXUALLY_EXPLICIT": "BLOCK_NONE", "HARM_CATEGORY_DANGEROUS_CONTENT": "BLOCK_NONE", "HARM_CATEGORY_HARASSMENT": "BLOCK_NONE"}` | 否   |
| `generation_config` | object  | Gemini API 的生成参数。                                                                                                               | `{"top_p": 1, "top_k": 1, "temperature": 0.7, "max_output_tokens": 2000}`                                                         | 否   |
| `system_prompt`     | string  | 系统提示，用于设定 AI 的角色、行为或背景信息。                                                                                            | `"你是一个乐于助人的AI助手。"`                                                                                                         | 否   |

### 3. `log` (日志设置)

| 键          | 类型   | 描述                                      | 默认值              | 必需 |
| :---------- | :----- | :---------------------------------------- | :------------------ | :--- |
| `level`     | string | 日志记录级别 (DEBUG, INFO, WARNING, ERROR) | `"INFO"`            | 否   |
| `file_path` | string | 日志文件保存路径。                        | `"./logs/app.log"` | 否   |

### 4. `settings` (全局功能开关与默认限制)

这是全局默认设置的地方，同时也控制着功能的总开关。此处的 `enable_*` 开关会覆盖所有较低层级的设置。

| 键                               | 类型    | 描述                                                                                                             | 默认值    | 必需 |
| :------------------------------- | :------ | :--------------------------------------------------------------------------------------------------------------- | :-------- | :--- |
| `enable_personality_retrain`     | boolean | 允许使用 `修改系统提示词` 命令 (需要 `enable_ai_chat` 也为 `true`)。也影响是否在查看/回滚对话时跳过系统提示。 | `false`   | 否   |
| `enable_history_edit`            | boolean | 允许管理员/有权限者使用特定格式 (`{'role':...}`) 直接编辑对话历史。                                                | `false`   | 否   |
| `enable_ai_chat`                 | boolean | **全局** AI 对话功能总开关。如果关闭，所有 AI 对话及相关命令（重置、回滚等）将禁用。                                  | `true`    | 否   |
| `enable_chat_commands`           | boolean | **全局** 聊天命令（如 `帮助`, `语音开启/关闭`, `设置` 等）总开关。                                                      | `true`    | 否   |
| `enable_random_events`           | boolean | **全局** 随机事件总开关。                                                                                        | `false`   | 否   |
| `enable_repeat_event`            | boolean | **全局** 随机复读事件开关（需要 `enable_random_events` 也为 `true` 才能生效）。                                      | `false`   | 否   |
| `message_rate_limit`             | integer | 默认的每小时 AI 消息频率限制 (对普通用户)。设置为 0 或负数表示无限制。                                              | `30`      | 否   |
| `default_send_voice`             | boolean | 新会话默认是否开启语音回复。                                                                                     | `false`   | 否   |
| `at_user_in_group_response`      | boolean | 在群聊中回复时，是否自动 @ 发送消息的用户。                                                                      | `true`    | 否   |
| `auto_confirm`                   | boolean | **不推荐在此设置**，请使用 `qq_bot.auto_confirm` 控制全局行为。群组特定自动确认可配置在 `group.<id>.settings.auto_confirm`。 | (无)      | 否   |
| `join_keyword`                   | string  | **不推荐在此设置**，请在 `group.<id>.settings.join_keyword` 中配置特定群组的加入关键词。                            | (无)      | 否   |

### 5. `random_events` (随机事件配置)

包含各种随机事件的**默认参数**。事件是否真正触发还受 `settings.enable_random_events` 和特定事件的全局开关（如 `settings.enable_repeat_event`）以及层级配置中的 `enabled` 值控制。

*   **`repeat`** (随机复读事件)
    | 键                  | 类型    | 描述                                                                                                                                                              | 默认值        | 必需 |
    | :------------------ | :------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------ | :--- |
    | `id`                | string  | 事件的唯一标识符。                                                                                                                                                  | `"repeat"`    | 是   |
    | `name`              | string  | 事件的名称（用于日志等）。                                                                                                                                          | `"随机复读"`    | 否   |
    | `description`       | string  | 事件的描述（用于帮助信息等）。                                                                                                                                      | `"随机复读群内消息"` | 否   |
    | `enabled`           | boolean | 此事件类型在**默认情况**下是否启用。会被全局开关 (`settings.enable_repeat_event`, `settings.enable_random_events`) 和更高层级的配置（如群组特定设置）覆盖。        | `false`       | 否   |
    | `probability`       | float   | 每次收到消息时触发此事件的概率 (0.0 到 1.0)。                                                                                                                      | `0.05`        | 否   |
    | `min_interval`      | integer | **个人**冷却时间（秒）。同一用户在此上下文（群组或私聊）触发一次后，需要等待多少秒才能再次触发此事件。`-1` 表示无个人冷却，此时 `shared_min_interval` 才可能生效。 | `-1`          | 否   |
    | `shared_min_interval` | integer | **群组共享**冷却时间（秒）。**仅当** `min_interval` 为 `-1` 且在群聊中时生效。在某个群组触发一次后，整个群组需要等待多少秒才能再次触发此事件。                     | `60`          | 否   |

*(未来可以添加其他随机事件配置块)*

### 6. `proxy` (网络代理设置)

| 键           | 类型   | 描述                                                              | 默认值 | 必需 |
| :----------- | :----- | :---------------------------------------------------------------- | :----- | :--- |
| `https_proxy` | string | 设置 HTTPS 代理地址 (例如 `"http://127.0.0.1:7890"`)。`null` 则不使用。 | `null` | 否   |

### 7. `permissions` (权限数据)

*   **`users`**: (object) 存储用户特定权限信息。
    *   **`<user_id>`**: (object) 用户的 QQ 号作为键 (字符串)。
        *   `roles`: (list) 用户拥有的角色列表 (字符串)。例如 `["private_user", "group_manager"]`。可用角色见下文。
        *   `managed_groups`: (list) 如果用户拥有 `group_manager` 角色，这里列出他们管理的群号 (字符串列表)。
        *   `blacklisted_in`: (list) 用户在哪些群组中被拉黑 (字符串列表)。

**可用角色常量 (代码中使用):**

*   `admin`: 管理员，拥有最高权限。通常自动授予 `qq_bot.admin_qq`。
*   `group_manager`: 群管理员，可以管理特定群组的设置和黑名单（需要配合 `managed_groups` 列表）。
*   `private_user`: 允许与机器人私聊的用户。
*   `group_blacklisted`: 在特定群组中被拉黑（仅在 `blacklisted_in` 列表中体现，不是一个直接赋予的角色标签）。
*   `global_blacklisted`: 全局黑名单，禁止所有交互。
*   `user`: 普通用户（隐式角色，无需配置）。

**示例:**

```json
"permissions": {
  "users": {
    "80856814": { // 管理员QQ (假设在 qq_bot.admin_qq 中也配置了)
      "roles": ["admin", "private_user"], // admin 角色会被代码自动识别和添加（如果配置中没有）
      "managed_groups": [],
      "blacklisted_in": []
    },
    "10002": { // 一个群管理员兼私聊用户
      "roles": ["group_manager", "private_user"],
      "managed_groups": ["12345678"], // 管理群 12345678
      "blacklisted_in": []
    },
    "10003": { // 一个在某群被拉黑的用户 (注意：没有 group_blacklisted 角色标签)
      "roles": [], // 可能有其他角色，如 private_user
      "managed_groups": [],
      "blacklisted_in": ["87654321"] // 在群 87654321 中被拉黑
    },
    "10004": { // 一个全局黑名单用户
        "roles": ["global_blacklisted"],
        "managed_groups": [],
        "blacklisted_in": [] // 全局黑名单时，此项无意义
    }
  }
}
```

### 8. `group` (群组配置)

此部分定义群聊相关的配置，采用分层结构。

*   **`__default__`**: (object) 全局群组配置的默认值。
    *   `user`: (object) 对普通群成员生效的默认设置。
        *   `settings`: (object) 功能开关和限制，结构同顶层 `settings`，但只包含适用于群聊用户的部分（如 `message_rate_limit`, `enable_ai_chat` 等）。**注意:** 此处的 `enable_*` 开关会被顶层 `settings` 的同名开关覆盖。
        *   `random_events`: (object) 随机事件配置，结构同顶层 `random_events`，但只包含事件参数（如 `repeat.probability`, `repeat.enabled` 等）。
        *   `gemini`: (object) 可选，覆盖 Gemini 的默认参数 (如 `system_prompt`, `generation_config`)。
        *   `qq_bot`: (object) 可选，覆盖 QQ Bot 的默认参数 (如 `bot_name`, `voice`)。
    *   `manager`: (object) 对群管理员生效的默认设置（结构同 `user`）。
    *   `blacklisted`: (object) 对群内黑名单用户生效的默认设置（结构同 `user`，通常用于禁用功能）。
*   **`<group_id>`**: (object) 特定群组的配置，群号作为键 (字符串)。
    *   结构同 `__default__` (`user`, `manager`, `blacklisted` 配置块)。
    *   此处的设置会覆盖 `__default__` 中的同名设置。
    *   **`settings`**: (object, 可选) 可直接在此层级定义设置，适用于该群所有角色（除非被角色特定或用户特定设置覆盖），例如 `auto_confirm`, `join_keyword`。
    *   **`__specific_user__`**: (object, 可选) 用于定义该群组内特定用户的覆盖设置。
        *   **`<user_id>`**: (object) 用户的 QQ 号作为键 (字符串)。
            *   `settings`: (object) 覆盖该用户在此群的 `settings`。
            *   `random_events`: (object) 覆盖该用户在此群的 `random_events` 参数。
            *   `gemini`: (object) 覆盖该用户在此群的 `gemini` 参数。
            *   `qq_bot`: (object) 覆盖该用户在此群的 `qq_bot` 参数。

**示例:**

```json
"group": {
  "__default__": { // 全局默认
    "user": {
      "settings": { "message_rate_limit": 20, "enable_ai_chat": true }, // AI默认在群聊开启
      "random_events": { "repeat": { "probability": 0.03, "enabled": true, "shared_min_interval": 60, "min_interval": -1 } } // 复读默认开启
    },
    "manager": {
      "settings": { "message_rate_limit": 100, "enable_ai_chat": true },
      "random_events": { "repeat": { "probability": 0.01, "enabled": true } }
    },
    "blacklisted": {
      "settings": { "enable_ai_chat": false, "enable_chat_commands": false, "enable_random_events": false }
    }
  },
  "12345678": { // 特定群组 12345678 的配置
    "settings": { "enable_ai_chat": false }, // 在这个特定群组默认关闭 AI
    "user": { // 覆盖默认 user 设置
      "settings": { "message_rate_limit": 15 }, // 降低此群普通用户频率 (AI仍关闭)
      "random_events": { "repeat": { "probability": 0.01 } } // 降低此群复读概率
    },
    "manager": { // 群管在此群也受群组总开关影响
        "settings": { "enable_ai_chat": true } // 但可以为群管单独开启 AI
    },
    // blacklisted 未定义，将继承或从 __default__ 复制
    "__specific_user__": {
      "98765432": { // 此群的特定用户 98765432
        "settings": { "message_rate_limit": 50, "enable_ai_chat": true } // 给他更高的频率限制并开启 AI
      }
    }
  }
}
```

### 9. `private` (私聊配置)

结构类似于 `group`，但通常更简单。

*   **`__default__`**: (object) 全局私聊配置的默认值。
    *   `user`: (object) 对允许私聊的用户 (`private_user` 或 `admin`) 生效的默认设置。
        *   `settings`: (object) 功能开关和限制。
        *   `random_events`: (object) 随机事件配置（如果私聊需要随机事件）。
        *   `gemini`: (object) 可选，覆盖 Gemini 的默认参数。
        *   `qq_bot`: (object) 可选，覆盖 QQ Bot 的默认参数。
    *   *(通常不需要 `manager` 或 `blacklisted` 块，因为私聊权限由 `permissions` 控制)*
*   **`__specific_user__`**: (object, 可选) 用于定义特定用户的私聊覆盖设置。
    *   **`<user_id>`**: (object) 用户的 QQ 号作为键 (字符串)。
        *   `settings`: (object) 覆盖该用户的 `settings`。
        *   `random_events`: (object) 覆盖该用户的 `random_events` 参数。
        *   `gemini`: (object) 覆盖该用户的 `gemini` 参数。
        *   `qq_bot`: (object) 覆盖该用户的 `qq_bot` 参数。

### 10. `service` (Web 服务设置)

| 键             | 类型    | 描述                                                         | 默认值        | 必需 |
| :------------- | :------ | :----------------------------------------------------------- | :------------ | :--- |
| `host`         | string  | Flask 服务监听的主机地址。`0.0.0.0` 表示监听所有接口。       | `"127.0.0.1"` | 否   |
| `port`         | integer | Flask 服务监听的端口号。                                     | `5555`        | 否   |
| `use_reloader` | boolean | 是否启用 Flask 的自动重载功能（用于开发，生产环境建议 `false`）。 | `false`       | 否   |

## 重要提示

*   **备份:** 在进行重大修改之前，请备份你的 `config.json` 文件。
*   **验证:** 确保你的 JSON 文件格式正确。可以使用在线 JSON 验证器检查。
*   **必需项:** 确保所有标记为“是”的必需项都已正确填写，特别是 `qq_no`, `admin_qq`, `gemini.api_keys`，否则机器人可能无法启动。
*   **安全:** 不要将包含敏感信息（如 API Key）的 `config.json` 文件公开分享。
*   **路径:** `image_path` 和 `voice_path` 需要指向 go-cqhttp 可以访问的目录，通常是 go-cqhttp 数据目录下的 `images` 和 `voices` 子目录。