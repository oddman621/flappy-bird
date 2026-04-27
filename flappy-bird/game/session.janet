(import ./component)

(defn make-session []
  @{:bird (component/make-bird) # make-bird에 매개변수를 받아 외부로부터 설정이 주입되는 일관성이 필요할듯
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

