// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '计算器';

  @override
  String get calcError => '错误';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionTheme => '主题';

  @override
  String get themeLight => '明亮';

  @override
  String get themeDark => '暗黑';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get sectionLanguage => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get sectionFileBrowser => '文件浏览';

  @override
  String get showHiddenTitle => '显示隐藏文件 / 文件夹';

  @override
  String get showHiddenSubtitle => '以\".\"开头的项目，例如 .thumbnails';

  @override
  String get sectionUnlockSequence => '解锁序列';

  @override
  String currentSequence(String sequence) {
    return '当前：$sequence';
  }

  @override
  String get draftPlaceholder => '请通过下方键盘输入';

  @override
  String get clearTooltip => '清空';

  @override
  String get saveSequence => '保存解锁序列';

  @override
  String get sequenceSaved => '解锁序列已保存';

  @override
  String sequenceLengthError(int min, int max) {
    return '长度需在 $min-$max 位之间';
  }

  @override
  String get sequenceCharsError => '只能包含 0-9 / + - × ÷ % = ± . AC';

  @override
  String get sequenceHelp =>
      '可用字符：0-9 + - × ÷ % = ± . AC。在计算器主界面按下同样的键序列即可静默解锁；窗口式匹配，所以序列可以\"藏\"在更长的算式末尾。';

  @override
  String get permissionTitle => '需要存储权限';

  @override
  String get permissionExplanation =>
      '为了浏览隐藏文件夹（包括以 . 开头的目录）下的图片，本应用需要\"所有文件访问\"权限。';

  @override
  String get permissionGrant => '授予权限';

  @override
  String get permissionOpenSettings => '打开系统设置';

  @override
  String get permissionHint =>
      '提示：在 Android 11+ 上系统会跳到\"所有文件访问\"列表，请找到\"计算器\"并打开开关，然后返回本应用。';

  @override
  String get folderPickerTitle => '选择文件夹';

  @override
  String folderPickerSubtitle(int folders, int images, String sortLabel) {
    return '$folders 个文件夹 · $images 张图片 · $sortLabel';
  }

  @override
  String get sortTooltip => '排序方式';

  @override
  String get homeStorageTooltip => '回到主存储';

  @override
  String get settingsTooltip => '设置';

  @override
  String get immersivePreview => '沉浸预览';

  @override
  String get noAccessibleContent => '当前位置没有可访问的内容。\n请检查\"所有文件访问\"权限是否已授予。';

  @override
  String get emptyHere => '此处空空如也';

  @override
  String get parentFolderSubtitle => '返回上一级';

  @override
  String gallerySubtitleNoZoom(int images, String sortLabel) {
    return '$images 张图片 · $sortLabel';
  }

  @override
  String gallerySubtitleZoom(int images, String sortLabel, int columns) {
    return '$images 张图片 · $sortLabel · $columns 列';
  }

  @override
  String get noImages =>
      '此文件夹中没有可识别的图片。\n（支持 jpg/jpeg/png/gif/webp/bmp/heic/heif）';

  @override
  String get sortMenuNameAsc => '名称 升序 (A→Z)';

  @override
  String get sortMenuNameDesc => '名称 降序 (Z→A)';

  @override
  String get sortMenuModifiedDesc => '修改时间 降序 (新→旧)';

  @override
  String get sortMenuModifiedAsc => '修改时间 升序 (旧→新)';

  @override
  String get sortLabelNameAsc => '名称 · 升序';

  @override
  String get sortLabelNameDesc => '名称 · 降序';

  @override
  String get sortLabelModifiedAsc => '修改时间 · 升序';

  @override
  String get sortLabelModifiedDesc => '修改时间 · 降序';

  @override
  String get imageInfoTooltip => '信息';

  @override
  String get imageInfoTitle => '图片信息';

  @override
  String get imageInfoCloseTooltip => '关闭';

  @override
  String get imageInfoLoading => '正在加载…';

  @override
  String get imageInfoUnknown => '—';

  @override
  String get imageInfoPath => '路径';

  @override
  String get imageInfoType => '类型';

  @override
  String get imageInfoResolution => '分辨率';

  @override
  String get imageInfoSize => '大小';

  @override
  String get imageInfoCreated => '创建时间';

  @override
  String get imageInfoModified => '修改时间';

  @override
  String get imageInfoLocation => '位置';

  @override
  String get imageInfoCamera => '相机';

  @override
  String get imageInfoCameraParams => '参数';

  @override
  String imageInfoResolutionValue(int width, int height) {
    return '$width × $height';
  }
}

/// The translations for Chinese, as used in Hong Kong (`zh_HK`).
class AppLocalizationsZhHk extends AppLocalizationsZh {
  AppLocalizationsZhHk() : super('zh_HK');

  @override
  String get appTitle => '計算機';

  @override
  String get calcError => '錯誤';

  @override
  String get settingsTitle => '設定';

  @override
  String get sectionTheme => '主題';

  @override
  String get themeLight => '明亮';

  @override
  String get themeDark => '暗黑';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get sectionLanguage => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get sectionFileBrowser => '檔案瀏覽';

  @override
  String get showHiddenTitle => '顯示隱藏檔案 / 資料夾';

  @override
  String get showHiddenSubtitle => '以\".\"開頭的項目，例如 .thumbnails';

  @override
  String get sectionUnlockSequence => '解鎖序列';

  @override
  String currentSequence(String sequence) {
    return '目前：$sequence';
  }

  @override
  String get draftPlaceholder => '請以下方鍵盤輸入';

  @override
  String get clearTooltip => '清空';

  @override
  String get saveSequence => '儲存解鎖序列';

  @override
  String get sequenceSaved => '解鎖序列已儲存';

  @override
  String sequenceLengthError(int min, int max) {
    return '長度需在 $min-$max 位之間';
  }

  @override
  String get sequenceCharsError => '只能包含 0-9 / + - × ÷ % = ± . AC';

  @override
  String get sequenceHelp =>
      '可用字元：0-9 + - × ÷ % = ± . AC。在計算機主畫面按下同樣的鍵序列即可靜默解鎖；採用窗口匹配，所以序列可以\"藏\"在更長的算式末尾。';

  @override
  String get permissionTitle => '需要儲存權限';

  @override
  String get permissionExplanation =>
      '為瀏覽隱藏資料夾（包括以 . 開頭的目錄）下的圖片，本應用需要\"所有檔案存取\"權限。';

  @override
  String get permissionGrant => '授予權限';

  @override
  String get permissionOpenSettings => '開啟系統設定';

  @override
  String get permissionHint =>
      '提示：在 Android 11+ 上系統會跳至\"所有檔案存取\"列表，請找到\"計算機\"並開啟，然後返回本應用。';

  @override
  String get folderPickerTitle => '選擇資料夾';

  @override
  String folderPickerSubtitle(int folders, int images, String sortLabel) {
    return '$folders 個資料夾 · $images 張圖片 · $sortLabel';
  }

  @override
  String get sortTooltip => '排序方式';

  @override
  String get homeStorageTooltip => '回到主儲存空間';

  @override
  String get settingsTooltip => '設定';

  @override
  String get immersivePreview => '沉浸預覽';

  @override
  String get noAccessibleContent => '目前位置沒有可存取的內容。\n請確認\"所有檔案存取\"權限是否已授予。';

  @override
  String get emptyHere => '此處空空如也';

  @override
  String get parentFolderSubtitle => '返回上一層';

  @override
  String gallerySubtitleNoZoom(int images, String sortLabel) {
    return '$images 張圖片 · $sortLabel';
  }

  @override
  String gallerySubtitleZoom(int images, String sortLabel, int columns) {
    return '$images 張圖片 · $sortLabel · $columns 欄';
  }

  @override
  String get noImages =>
      '此資料夾中沒有可識別的圖片。\n（支援 jpg/jpeg/png/gif/webp/bmp/heic/heif）';

  @override
  String get sortMenuNameAsc => '名稱 升冪 (A→Z)';

  @override
  String get sortMenuNameDesc => '名稱 降冪 (Z→A)';

  @override
  String get sortMenuModifiedDesc => '修改時間 降冪 (新→舊)';

  @override
  String get sortMenuModifiedAsc => '修改時間 升冪 (舊→新)';

  @override
  String get sortLabelNameAsc => '名稱 · 升冪';

  @override
  String get sortLabelNameDesc => '名稱 · 降冪';

  @override
  String get sortLabelModifiedAsc => '修改時間 · 升冪';

  @override
  String get sortLabelModifiedDesc => '修改時間 · 降冪';

  @override
  String get imageInfoTooltip => '資訊';

  @override
  String get imageInfoTitle => '圖片資訊';

  @override
  String get imageInfoCloseTooltip => '關閉';

  @override
  String get imageInfoLoading => '載入中…';

  @override
  String get imageInfoUnknown => '—';

  @override
  String get imageInfoPath => '路徑';

  @override
  String get imageInfoType => '類型';

  @override
  String get imageInfoResolution => '解析度';

  @override
  String get imageInfoSize => '大小';

  @override
  String get imageInfoCreated => '建立時間';

  @override
  String get imageInfoModified => '修改時間';

  @override
  String get imageInfoLocation => '位置';

  @override
  String get imageInfoCamera => '相機';

  @override
  String get imageInfoCameraParams => '參數';

  @override
  String imageInfoResolutionValue(int width, int height) {
    return '$width × $height';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '計算機';

  @override
  String get calcError => '錯誤';

  @override
  String get settingsTitle => '設定';

  @override
  String get sectionTheme => '主題';

  @override
  String get themeLight => '明亮';

  @override
  String get themeDark => '暗黑';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get sectionLanguage => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get sectionFileBrowser => '檔案瀏覽';

  @override
  String get showHiddenTitle => '顯示隱藏檔案 / 資料夾';

  @override
  String get showHiddenSubtitle => '以「.」開頭的項目，例如 .thumbnails';

  @override
  String get sectionUnlockSequence => '解鎖序列';

  @override
  String currentSequence(String sequence) {
    return '目前：$sequence';
  }

  @override
  String get draftPlaceholder => '請以下方鍵盤輸入';

  @override
  String get clearTooltip => '清除';

  @override
  String get saveSequence => '儲存解鎖序列';

  @override
  String get sequenceSaved => '解鎖序列已儲存';

  @override
  String sequenceLengthError(int min, int max) {
    return '長度需在 $min-$max 位之間';
  }

  @override
  String get sequenceCharsError => '只能包含 0-9 / + - × ÷ % = ± . AC';

  @override
  String get sequenceHelp =>
      '可用字元：0-9 + - × ÷ % = ± . AC。在計算機主畫面按下相同的鍵序列即可靜默解鎖；採用視窗匹配，所以序列可以「藏」在更長的算式末尾。';

  @override
  String get permissionTitle => '需要儲存權限';

  @override
  String get permissionExplanation =>
      '為瀏覽隱藏資料夾（包括以 . 開頭的目錄）下的圖片，本應用程式需要「所有檔案存取」權限。';

  @override
  String get permissionGrant => '授予權限';

  @override
  String get permissionOpenSettings => '開啟系統設定';

  @override
  String get permissionHint =>
      '提示：在 Android 11+ 上系統會跳至「所有檔案存取」清單，請找到「計算機」並開啟，然後返回本應用程式。';

  @override
  String get folderPickerTitle => '選擇資料夾';

  @override
  String folderPickerSubtitle(int folders, int images, String sortLabel) {
    return '$folders 個資料夾 · $images 張圖片 · $sortLabel';
  }

  @override
  String get sortTooltip => '排序方式';

  @override
  String get homeStorageTooltip => '回到主儲存空間';

  @override
  String get settingsTooltip => '設定';

  @override
  String get immersivePreview => '沉浸預覽';

  @override
  String get noAccessibleContent => '目前位置沒有可存取的內容。\n請確認「所有檔案存取」權限是否已授予。';

  @override
  String get emptyHere => '此處空空如也';

  @override
  String get parentFolderSubtitle => '返回上一層';

  @override
  String gallerySubtitleNoZoom(int images, String sortLabel) {
    return '$images 張圖片 · $sortLabel';
  }

  @override
  String gallerySubtitleZoom(int images, String sortLabel, int columns) {
    return '$images 張圖片 · $sortLabel · $columns 欄';
  }

  @override
  String get noImages =>
      '此資料夾中沒有可辨識的圖片。\n（支援 jpg/jpeg/png/gif/webp/bmp/heic/heif）';

  @override
  String get sortMenuNameAsc => '名稱 遞增 (A→Z)';

  @override
  String get sortMenuNameDesc => '名稱 遞減 (Z→A)';

  @override
  String get sortMenuModifiedDesc => '修改時間 遞減 (新→舊)';

  @override
  String get sortMenuModifiedAsc => '修改時間 遞增 (舊→新)';

  @override
  String get sortLabelNameAsc => '名稱 · 遞增';

  @override
  String get sortLabelNameDesc => '名稱 · 遞減';

  @override
  String get sortLabelModifiedAsc => '修改時間 · 遞增';

  @override
  String get sortLabelModifiedDesc => '修改時間 · 遞減';

  @override
  String get imageInfoTooltip => '資訊';

  @override
  String get imageInfoTitle => '圖片資訊';

  @override
  String get imageInfoCloseTooltip => '關閉';

  @override
  String get imageInfoLoading => '載入中…';

  @override
  String get imageInfoUnknown => '—';

  @override
  String get imageInfoPath => '路徑';

  @override
  String get imageInfoType => '類型';

  @override
  String get imageInfoResolution => '解析度';

  @override
  String get imageInfoSize => '大小';

  @override
  String get imageInfoCreated => '建立時間';

  @override
  String get imageInfoModified => '修改時間';

  @override
  String get imageInfoLocation => '位置';

  @override
  String get imageInfoCamera => '相機';

  @override
  String get imageInfoCameraParams => '參數';

  @override
  String imageInfoResolutionValue(int width, int height) {
    return '$width × $height';
  }
}
