# Point of View

一个伪装成"计算器"的 Android 图片浏览器，专门用来查看 Android 系统相册不会显示的隐藏目录（以 `.` 开头的文件夹、含 `.nomedia` 的目录等）下的图片。

> 仅支持 Android。其他平台的脚手架已经从工程中移除。

## 它能做什么

- **桌面伪装**：图标和应用名都是"计算器"，主界面是一个完全可用的 iOS 风格四则运算计算器（`+ - × ÷ % ± . AC =`）。
  - 输入时主显示区会显示完整算式（例如 `123+456`）；按下 `=` 后主显示切换为结果（`579`），上方以小一号、半透明字号同步显示原算式作为历史。
- **隐藏入口**：在计算器中按下用户配置的 _解锁序列_，会静默跳转到图片浏览器；返回时计算器自动重置，毫无痕迹。
  - 默认解锁序列：`0000`
  - 可在"设置"里改成任意 4–12 位、由 `0-9 + - × ÷ % = ± . AC` 组成的序列。
  - 滑动窗口匹配 —— 序列可以"藏"在更长的算式末尾（例如设置为 `1+1=`，输入 `5+1+1=` 也会触发）。
- **自建文件夹浏览器**：从 `/storage/emulated/0` 开始，列出全部子目录 + 当前目录下的图片缩略图行；面包屑可一路点到根。
  - 隐藏项（以 `.` 开头）默认展示，淡色斜体加 `folder_special` 图标加以区分；可在设置中关闭显示。
- **图片网格 + 沉浸看图**：选定文件夹后可进入纯网格的"沉浸看图模式"。两种入口都用同一个 `PhotoViewGallery` 全屏查看器：左右滑动翻页、双击缩放、双指捏合缩放/平移，Hero 过渡。
- **网格双指捏合缩放**：在沉浸看图的网格上两指捏合即可在 2–12 列之间无级缩放；当列数 ≥ 6 时会按当前排序自动分组并加上分组标题（按名称排序时按首字母分组，按修改时间排序时按"年-月"分组）。
- **可拖动滚动条**：文件夹列表与沉浸网格滚动时会显示滚动条，按住滑块时自动加粗，可直接拖动跳到任意位置，长目录翻找更高效。
- **可配置排序**：4 种方式（名称 ↑↓、修改时间 ↑↓），文件夹和图片各自独立排序、目录恒在前；选择持久化。
- **多语言**：内置简体中文、English、繁體中文（香港）、繁體中文（臺灣）。默认跟随系统语言；系统语言不在支持列表时回退到英文，可在设置中显式覆盖。
- **明亮 / 暗黑 / 跟随系统**主题，所有界面（包括计算器）随之自动切换。

## 截图

计算器界面：
<img width="558" height="1240" alt="a7a2657294493caf48d2d740cc181ca3" src="https://github.com/user-attachments/assets/04810efc-4b29-4fe8-a555-ae533fc1b05a" />

文件列表：
<img width="558" height="1240" alt="1e8c21240ccc823d9a305ced3f0aabe8" src="https://github.com/user-attachments/assets/6d18473f-4973-426a-8047-9e852c09d12f" />


沉浸预览：
<img width="558" height="1240" alt="a4c022ded4c29e4fb48f85dacd4d51d0" src="https://github.com/user-attachments/assets/5baafd79-2a46-4570-9f00-4f1141711730" />


图片查看：
<img width="558" height="1240" alt="e05ca3ab203063a80c504c43053b4a02" src="https://github.com/user-attachments/assets/7beae435-4339-4e2e-944c-97e48cbf28f5" />



## 权限

第一次跳转到图片浏览器时会要求 **"所有文件访问"权限**（Android 11+ 的 `MANAGE_EXTERNAL_STORAGE`）。这是访问任意文件系统路径所必需的，因为系统的 `READ_MEDIA_IMAGES` 不允许浏览隐藏目录。

授权步骤：
1. 在权限页点击 **授予权限** → 系统会跳到"所有文件访问"列表；
2. 找到 **计算器** 并打开开关；
3. 返回 App，权限页自动刷新进入文件夹浏览器。

> 由于这个权限受 Google Play 限制，本应用面向**侧载/自用场景**，不适合上架。

## 运行 / 构建

需要 Flutter ≥ 3.18.0 与 Android SDK。

```bash
flutter pub get

# 真机调试
flutter run

# 出 release APK（默认 fat APK，~48MB）
flutter build apk --release
```

### 打更小的 release 包

`flutter build apk --release` 默认把 3 套 ABI（armeabi-v7a / arm64-v8a / x86_64）的 Flutter Engine 全塞进同一个 APK，体积接近 50MB。仓库根目录提供一个 `Makefile` 把推荐的瘦身参数封装成一条命令：

```bash
make release   # 拆 ABI + Dart 混淆，每个 APK ~17MB，输出到 release-artifacts/<version>/
make arm64     # 同上，但只保留 arm64-v8a 那个（侧载到现代安卓机就用这个）
make install   # adb 安装上一步产出的 arm64 APK
make clean     # flutter clean + 删除 release-artifacts/
```

实际等价于：

```bash
flutter build apk --release \
  --split-per-abi \
  --obfuscate --split-debug-info=build/symbols/<version>
```

> 混淆后的崩溃栈无法直接看；务必把 `build/symbols/<version>/` 备份归档，
> 之后用 `flutter symbolize -i <stack.txt> -d build/symbols/<version>/app.android-arm64.symbols`
> 还原。

## 项目结构

```
lib/
├── main.dart                     # 入口；MaterialApp 监听 Theme/Locale ValueNotifier
├── l10n/
│   ├── app_en.arb                # 翻译模板（English）
│   ├── app_zh.arb                # 简体中文（zh / zh_CN）
│   ├── app_zh_HK.arb             # 繁體中文（香港）
│   ├── app_zh_TW.arb             # 繁體中文（臺灣）
│   ├── labels.dart               # SortOption / ThemeMode 的本地化标签辅助
│   └── generated/                # gen_l10n 产物（AppLocalizations）
├── models/
│   └── sort_option.dart          # SortField / SortOrder + 序列化
├── services/
│   ├── file_service.dart         # 列目录、列图片、按 SortOption 排序，可选过滤隐藏项
│   ├── hidden_files_service.dart # 「显示隐藏文件 / 文件夹」开关 + 持久化
│   ├── locale_service.dart       # 当前语言 ValueNotifier + 系统语言三段式回退
│   ├── permission_service.dart   # MANAGE_EXTERNAL_STORAGE 检查/申请
│   ├── prefs_service.dart        # 排序、上次浏览路径持久化
│   ├── secret_service.dart       # 解锁序列（含字母表常量、display 工具）
│   └── theme_service.dart        # ThemeMode + ValueNotifier
├── screens/
│   ├── calculator_screen.dart    # 伪装首页 + 完整算式显示 + 滑动窗口 secret 检测
│   ├── permission_gate.dart      # 权限闸门（接受 child）
│   ├── folder_picker_screen.dart # 自建文件夹浏览器（folders + image tiles）
│   ├── gallery_screen.dart       # 纯图网格 + 双指捏合缩放 + 分组标题
│   ├── image_viewer_screen.dart  # 全屏 PhotoViewGallery 查看器
│   └── settings_screen.dart      # 主题 / 语言 / 隐藏项开关 / 解锁序列编辑
└── widgets/
    └── folder_tile.dart          # 列表行（folder / image / parent ".." 工厂）
```

> 本地化使用 Flutter 官方 `gen_l10n`：修改 `lib/l10n/app_*.arb` 后运行
> `flutter gen-l10n`（或 `flutter pub get` 触发）即可重新生成
> `lib/l10n/generated/` 下的 `AppLocalizations` 类。

## 替换图标

启动器图标由 `flutter_launcher_icons` 从 [assets/icon/calculator_icon.png](assets/icon/calculator_icon.png) 生成。要换成新图：

```bash
cp <new-source>.png assets/icon/calculator_icon.png
dart run flutter_launcher_icons    # 重生成所有 mipmap-*/ic_launcher.png
```

## 主要依赖

| 包 | 用途 |
| --- | --- |
| [`flutter_localizations`](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) | 多语言（含 `MaterialLocalizations` 中文翻译） |
| [`intl`](https://pub.dev/packages/intl) | gen_l10n 生成的 `AppLocalizations` 运行时依赖 |
| [`permission_handler`](https://pub.dev/packages/permission_handler) | 申请 `MANAGE_EXTERNAL_STORAGE` |
| [`photo_view`](https://pub.dev/packages/photo_view) | 全屏图片查看器（双击/双指缩放、PageView 画廊） |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | 排序、主题、语言、隐藏项开关、解锁序列、上次路径持久化 |
| [`path`](https://pub.dev/packages/path) | 路径拼接、basename、扩展名 |
| [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) | 启动器图标生成（dev_dep） |
