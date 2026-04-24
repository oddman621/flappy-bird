(import ./bird :prefix "" :only [make-bird draw-bird bird-behaviors])
(import ./pipe :prefix "" :only [make-pipe draw-pipe collision-rect-upper collision-rect-lower])
(import ./storage)
(import jaylib)

# ------ helpers -------
(defn execute-behavior [actor behaviors & args]
  (let [behavior (get behaviors (get actor :state))]
    (behavior actor ;args)))

# ------ UI helpers -------
(defn draw-playing-ui [session]
  (jaylib/draw-text (string/format "Score: %d\nHiscore: %d" (session :score) (session :hiscore)) 0 0 20 :dark-green)
  (when (get session :paused)
    (jaylib/draw-text "PAUSE" 150 290 20 :dark-green)))

(defn draw-main-ui []
  (jaylib/draw-text "Press Space or Enter to Start" 50 290 20 :dark-green))

(defn draw-gameover-ui [session]
  (def hiscore-msg (if (< (session :hiscore) (session :score)) "\nNew Hiscore!" ""))
  (jaylib/draw-text (string/format "Game Over\n Score: %d%s" (get session :score) hiscore-msg) 150 290 20 :dark-green))


# ------- session --------
(defn make-session []
  @{:bird (make-bird)
    :gravity 0.5

    :pipes @[]
    :pipe-spawn-interval 3
    :pipe-spawn-timer 3
    :pipe-randomness 300
    :pipe-space 150

    :state :main
    :paused false
    :elapsed 0
    :score 0
    :hiscore 0})

(defn exists? [pred arr]
  (not (nil? (find pred arr))))

(defn bird-collided? [session]
  (let [bird (session :bird)
        bird-pos [(bird :x) (bird :y)]
        bird-rad (bird :radius)
        pipes (session :pipes)]
    (exists? (fn [pipe]
               (let [upper-rect (collision-rect-upper pipe)
                     lower-rect (collision-rect-lower pipe)]
                 (or (jaylib/check-collision-circle-rec bird-pos bird-rad upper-rect)
                     (jaylib/check-collision-circle-rec bird-pos bird-rad lower-rect))))
             pipes)))

(defn reset-session [session] 
  (def hiscore (session :hiscore))
  (merge-into session (make-session))
  (put session :hiscore hiscore))

(defn pipe-just-passed? [pipe bird]
  (if (and (not (pipe :passed)) (< (pipe :x) (bird :x)))
    (do (put pipe :passed true) 
        true)
    false))
(defn update-score [session]
  (each pipe (session :pipes)
    (when (pipe-just-passed? pipe (session :bird))
      (++ (session :score)))))
(defn update-hiscore [session]
  (when (< (session :hiscore) (session :score))
      (put session :hiscore (session :score))))

(defn pipe-process [session bird-vel delta-time]
  (let [pipes (session :pipes)]
    (+= (session :pipe-spawn-timer) delta-time)
    (when (>= (session :pipe-spawn-timer) (session :pipe-spawn-interval))
      (put session :pipe-spawn-timer 0)
      (array/push pipes (make-pipe (session :pipe-randomness) (session :pipe-space))))
    (each pipe pipes
      (resume (pipe :behavior) bird-vel)
      (when (false? (pipe :active))
        (when-let [idx (find-index |(= $ pipe) pipes)]
          (array/remove pipes idx))))))

(def session-behaviors
  {:main
   (fn [session _ jump-pressed pause-pressed]
     (when (or jump-pressed pause-pressed)
       (put session :state :playing)))
   :playing
   (fn [session delta-time jump-pressed pause-pressed]
     (let [paused (get session :paused)]
       (when pause-pressed
         (put session :paused (not paused)))
       (when (not paused)
         (+= (session :elapsed) delta-time)
         (let [bird (session :bird)]
           (if (= (get bird :state) :dead)
             (put session :state :gameover)
             (do
               (execute-behavior bird bird-behaviors jump-pressed (session :gravity))
               (when (= (get bird :state) :alive)
                 (do
                   (pipe-process session (bird :velocity-x) delta-time)
                   (update-score session)
                   (when (bird-collided? session)
                     (put bird :velocity-y (max 0 (bird :velocity-y)))
                     (put bird :state :falling))))))))))
   :gameover
   (fn [session _ jump-pressed pause-pressed]
     (when (or jump-pressed pause-pressed)
       (update-hiscore session)
       (storage/save-hiscore (session :hiscore))
       (reset-session session)))})

(def ui-behaviors
  {:main (fn [_] (draw-main-ui))
   :playing (fn [session] (draw-playing-ui session))
   :gameover (fn [session] (draw-gameover-ui session))})

(def render-behaviors
  {:main
   (fn [session]
     (draw-bird (get session :bird)))
   :playing
   (fn [session]
     (each pipe (session :pipes) (draw-pipe pipe))
     (draw-bird (get session :bird)))
   :gameover
   (fn [session]
     (each pipe (session :pipes) (draw-pipe pipe))
     (draw-bird (get session :bird)))})

(defn update-session [session delta-time jump-pressed pause-pressed]
  (execute-behavior session session-behaviors delta-time jump-pressed pause-pressed))

(defn draw-session [session]
  (execute-behavior session render-behaviors)
  (execute-behavior session ui-behaviors))
