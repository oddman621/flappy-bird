(import jaylib) # Windowing
(import ./game/render :as render :only [draw-session])
(import ./game/session :as session :only [make-session])
(import ./game/storage :as storage :only [load-hiscore])
(import ./game/game-logic :as logic)
(import ./game/asset :as asset)

# -------- windowing + etc --------
(defn init-window []
  (jaylib/init-window 400 600 "Janet Flappy Bird")
  (jaylib/set-target-fps 60)
  # (jaylib/set-exit-key 0)
  (jaylib/hide-cursor))
(defn deinit-window [] (jaylib/close-window)) 
(def bg-color [(/ 96 255) (/ 128 255) (/ 192 255)])

# -------- main --------
(defn main [& args]
  (init-window)
  (jaylib/init-audio-device)
  (asset/init-store)
  (defer
    (do
      (asset/deinit-store)
      (jaylib/close-audio-device)
      (deinit-window))
    (let [game-session (session/make-session)]
      (put game-session :hiscore (storage/load-hiscore))
      (while (not (jaylib/window-should-close))

        (let [jump (logic/jump-pressed?)
              pause (logic/pause-pressed?)
              delta (jaylib/get-frame-time)]
          (logic/update-session game-session delta jump pause))

        (jaylib/begin-drawing)
        (jaylib/clear-background bg-color)
        (render/draw-session game-session)
        (jaylib/end-drawing)))
    ))

