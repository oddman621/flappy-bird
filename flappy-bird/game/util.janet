## Common helpers here

(defn execute-behavior [actor behaviors & args]
  (let [behavior (get behaviors (get actor :state))]
    (behavior actor ;args)))

(defn exists? [pred arr]
  (not (nil? (find pred arr))))
