# Marp+
🔖 Markdown 做演示，一个应用就够了

![](https://ws1.sinaimg.cn/large/006tNbRwgy1fwdlnp7k6lj31kw15xk3k.jpg)

## 介绍
Marp 是日本开发者 [Yuki Hattori](https://github.com/yhatt) 多年前的作品，可通过 Markdown 简单制作演示文稿，但并不支持全屏放映。作者最近正在大幅重构 Marp，可能有什么宏伟的计划，因此也长期没有发布更新。

Marp とは日本ディベロッパーの [Yuki Hattori](https://github.com/yhatt) のアプリです。Marp は Markdown 言語で簡単にプレゼンテーションを作られます。プレゼンテーションを全画面表示の能力がなく、アップデートが非常に遅い場合でも、このツールは非常に便利です。

Marp+ 是基于 Marp 二次开发的，面向简体中文用户的加强版 Marp，它在 Marp 基础上进行修改，主要引入了以下新功能：

- UI 重做，极简风格更清爽，不再固定幻灯片尺寸，而是以 Web 形式自适应展示，支持快捷键调整字体大小；
- 带动画效果的幻灯片翻页展示，支持全屏演示，支持方向键翻页；
- 在原有支持 LaTeX 公式的基础上，增加支持 Mermaid 绘图；
- 允许直接使用 CSS 语法快速定制当前幻灯片样式，同时也保留 `<style>` tag 定制全局样式的支持。

## 使用
### 下载
#### macOS
从 [Releases](https://github.com/rikumi/marp-plus/releases/latest) 页面下载最新版本。

#### 其他平台
暂不编译其他平台的发布版本，如有需要，请参考「开发」一节手动编译使用。

### 用法和语法
- 按 `Esc` 隐藏/显示编辑栏，便于演示；
- 使用分割线语法 `---` 分页，分页前要留有空行，否则上一行将识别为标题；
- 可直接在分割线的下一行紧跟着设置当前页 CSS 样式，一行一个样式，结尾可不带分号；
- 仍可以使用 `<style>` 标签设置全局样式，在 DevTools 中可看到 DOM 结构作为参考；
- 在预览页中，使用 `←/→` 等按键进行翻页，使用 `⌘+/-` 缩放预览字体，`⌘0` 恢复预览字体。

## 开发
- 使用 `npm` 或 `yarn` 安装依赖；
- 使用 `npm run start` 编译预览；
- 使用 `gulp build` 编译发布版本。

## 反馈
### 已知问题
下列已知问题无需反馈：

1. 由于使用了 CodeMirror，编辑窗格对中文输入法的支持较差，会有一定兼容性问题；
2. 暂不支持导出 PDF，后续将会考虑恢复 PDF 支持。

### Issue 模板
Issue 不限语言和模板，可以使用任何人类可理解的语言进行交流。
This project has no limit in issue languages or templates.
Issue には言語やテンプレートの制限がありません。