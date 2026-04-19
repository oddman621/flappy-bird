(declare-project
  :name "flappy-bird"
  :description ```Flappy Bird with Janet ```
  :version "0.0.0"
  :dependencies ["jaylib"])

(declare-executable
  :name "flappy-bird"
  :entry "flappy-bird/init.janet")