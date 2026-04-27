(import ./asset)

# ------------ helper ---------

## anim: Animation Sequence (Tuple)
## loop: Means doesn't end
(defn anim-seq [anim loop?]
  (fn []
    (while true
      (for i 0 (length anim)
        (var elapsed 0)
        (let [duration (get-in anim [i :dur])]
          (while (< elapsed duration)
            (let [delta-time (yield (anim i))]
              (+= elapsed delta-time)))))
      (if-not loop? (break)))))

(defn make-anim-seq [anim loop?] (fiber/new (anim-seq anim loop?)))

# -------- TEMPLATE (no use?) -----------

(def animator/template
  {:asset :none
   :rect [0 0 0 0]
   :coro (fiber/new (fn [] (while true (yield))))})

# -------- COMPONENT ---------

(defn animator/add [obj asset-name coroutine]
  (def com
    @{:asset asset-name
      :rect [0 0 0 0]
   	  :coro coroutine})
      #:coro (logic/make-anim-seq (get-in asset/store [asset-name :animation anim]) loop?)})
  (put obj :animator com)
  obj)

# -------- SYSTEM ------------

(defn animator/update [com delta-time]
  (let [coroutine (com :coro)]
    (when (fiber/can-resume? coroutine)
      (put com :rect ((resume coroutine delta-time) :rect))))
  com)

(defn animator/change [com anim loop?]
  (put com :coro (make-anim-seq anim loop?))
  (put com :rect [0 0 0 0]))

# --------- FACTORY ----------

(defn make-bird []
  (def bird
    @{:x 100
      :y 300
      :radius 15
      :jump-impulse 11
      :velocity-x 2
      :velocity-y 0
      :state :alive})
  (animator/add bird :fanzon (make-anim-seq (get-in asset/store [:fanzon :meta :animations :flying]) true))
  bird)

# --------- FSM -----------