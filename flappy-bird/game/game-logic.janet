(import ./util)
(import ./pipe :prefix "" :only [make-pipe collision-rect-upper collision-rect-lower])
(import jaylib :only [check-collision-circle-rec key-pressed?])
(import ./bird :prefix "" :only [bird-behaviors])
(import ./storage)
(import ./session)

(defn bird-collided? [session]
  (let [bird (session :bird)
        bird-pos [(bird :x) (bird :y)]
        bird-rad (bird :radius)
        pipes (session :pipes)]
    (util/exists? (fn [pipe]
                    (let [upper-rect (collision-rect-upper pipe)
                          lower-rect (collision-rect-lower pipe)]
                      (or (jaylib/check-collision-circle-rec bird-pos bird-rad upper-rect)
                          (jaylib/check-collision-circle-rec bird-pos bird-rad lower-rect))))
                  pipes)))

(defn pipe-just-passed? [pipe bird]
  (if (and (not (pipe :passed)) (< (pipe :x) (bird :x)))
    (do (put pipe :passed true)
        true)
    false))

(defn update-score [session]
  (each pipe (session :pipes)
    (when (pipe-just-passed? pipe (session :bird))
      (++ (session :score)))))

(defn pipe-process [session bird-vel delta-time]
  (let [pipes (session :pipes)]
    (+= (session :pipe-spawn-timer) delta-time)
    (when (>= (session :pipe-spawn-timer) (session :pipe-spawn-interval))
      (put session :pipe-spawn-timer 0)
      (array/push pipes (make-pipe (session :pipe-randomness) (session :pipe-space))))
    (each pipe pipes
      (resume (pipe :behavior) bird-vel))
    (put session :pipes (filter (fn [p] (p :active)) pipes))))

(defn update-game-logic [session delta-time jump-pressed]
  (+= (session :elapsed) delta-time)
  (let [bird (session :bird)]
    (if (= (get bird :state) :dead)
      (put session :state :gameover)
      (do
        (util/execute-behavior bird bird-behaviors jump-pressed (session :gravity))
        (when (= (get bird :state) :alive)
          (do
            (pipe-process session (bird :velocity-x) delta-time)
            (update-score session)
            (when (bird-collided? session)
              (put bird :velocity-y (max 0 (bird :velocity-y)))
              (put bird :state :falling))))))))

(defn update-hiscore [session]
  (when (< (session :hiscore) (session :score))
    (put session :hiscore (session :score))))

(def session-behaviors
  {:main
   (fn [session _ jump-pressed pause-pressed]
     (when (or jump-pressed pause-pressed)
       (put session :state :playing)))
   :playing
   (fn [session delta-time jump-pressed pause-pressed]
     (let [paused (get session :paused)]
       (when pause-pressed (put session :paused (not paused)))
       (when (not paused)
         (update-game-logic session delta-time jump-pressed))))
   :gameover
   (fn [session _ jump-pressed pause-pressed]
     (when (or jump-pressed pause-pressed)
       (update-hiscore session)
       (storage/save-hiscore (session :hiscore))
       (session/reset-session session)))})

(defn update-session [session delta-time jump-pressed pause-pressed]
  (util/execute-behavior session session-behaviors delta-time jump-pressed pause-pressed))

# --------- input ------------

(defn jump-pressed? [] (jaylib/key-pressed? :space))
(defn pause-pressed? [] (jaylib/key-pressed? :enter))