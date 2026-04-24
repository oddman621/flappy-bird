(import ./bird :prefix "" :only [make-bird])

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

(defn reset-session [session] 
  (def hiscore (session :hiscore))
  (merge-into session (make-session))
  (put session :hiscore hiscore))

