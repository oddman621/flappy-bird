# 윈도우 환경을 상정함
# 멀티 플랫폼을 원하면 os/which 로 분기하면 됨
# (defn get-save-dir [app-name]
# (case (os/which)
#   :windows (path/join (os/getenv "LOCALAPPDATA") app-name)
#   :macos   (path/join (os/getenv "HOME") "Library" "Application Support" app-name)
#   :linux   (path/join (os/getenv "HOME") ".local" "share" app-name)
# # 기본값 (기타 환경)
#   (path/join (os/getenv "HOME") (string "." app-name))))

(def app-name "flappy-bird-janet")
(defn window-path [filename]
  (def window-dir (string/join [(os/getenv "LOCALAPPDATA") app-name] "\\"))
  (os/mkdir window-dir)
  (string/join [window-dir filename] "\\"))


(defn load-hiscore [] 
  (let [path (window-path "hiscore.txt")]
    (if (os/stat path)
      (with [f (file/open path :r)] (scan-number (file/read f :all)))
      0)))

(defn save-hiscore [score]
  (let [path (window-path "hiscore.txt")]
    (with [f (file/open path :w)] (file/write f (string score)))))
