# bird system utils
(import ./asset)
(import jaylib)

(defn reset-bird [bird]
  (put bird :x 100)
  (put bird :y 300)
  (put bird :velocity-x 3)
  (put bird :velocity-y 0)
  (put bird :state :alive))

(defn jump-bird [bird]
  (let [impulse (get bird :jump-impulse)]
    (put bird :velocity-y (- impulse))
    (jaylib/play-sound (asset/sound :jump))))

(defn drop-bird [bird gravity]
  (let [velocity-y (get bird :velocity-y)]
    (put bird :velocity-y (+ velocity-y gravity)))
  (let [velocity-y (get bird :velocity-y)
        y (get bird :y)]
    (put bird :y (+ y velocity-y))))

(defn fallen? [bird] (>= (get bird :y) 615))
(defn shot-down-bird [bird] 
  (put bird :velocity-y (max 0 (bird :velocity-y)))
  (jaylib/play-sound (asset/sound :falling))
  (put bird :state :falling)) 
(defn kill-bird [bird] (put bird :state :dead))

(def bird-behaviors
  {:alive (fn [bird jump-pressed gravity]
            (when jump-pressed (jump-bird bird))
            (drop-bird bird gravity)
            (when (fallen? bird) (kill-bird bird)))
   :falling (fn [bird _ gravity]
              (drop-bird bird gravity)
              (when (fallen? bird) (kill-bird bird)))
   :dead (fn [_ _ _] nil)})
