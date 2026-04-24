(import jaylib)
(import ./game/session :as session :only [make-session update-session draw-session])
(import ./game/storage :as storage)

# -------- helper --------
(defn init-window []
  (jaylib/init-window 400 600 "Janet Flappy Bird")
  (jaylib/set-target-fps 60)
  # (jaylib/set-exit-key 0)
  (jaylib/hide-cursor))
(defn deinit-window [] (jaylib/close-window))

# -------- main --------
(defn main [& args]
  (init-window)

  (def game-session (session/make-session))
  (put game-session :hiscore (storage/load-hiscore))
  (def bg-color [(/ 96 255) (/ 128 255) (/ 192 255)])
  (while (not (jaylib/window-should-close))

    (let [jump (jaylib/key-pressed? :space)
          pause (jaylib/key-pressed? :enter)
          delta (jaylib/get-frame-time)]
      (session/update-session game-session delta jump pause))

    (jaylib/begin-drawing)
    (jaylib/clear-background bg-color)
    (session/draw-session game-session)
    (jaylib/end-drawing))

  (deinit-window))

