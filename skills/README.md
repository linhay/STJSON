# STJSON Public Skills

这个目录是 STJSON 对外 skill bundle 的源码入口。

对外保留这些 public skills：

- `stjson-usage`
- `stjson-dev-feedback`
- `stjson-update`

发布时会把本目录打包成 `stjson-skills.tar.gz`，并在压缩包内使用 `STJSON.skills/` 作为安装根目录。

安装或升级时，将解压得到的 `STJSON.skills/` 放到 agent skills 目录下即可。仓库内部维护流程、实现流程、治理规则全部放在 `.agents/skills/`，不得混入这个 public bundle。
