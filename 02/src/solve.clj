(ns solve
  (:require [clojure.string :as s]))

(defn load-data [data-src]
  (s/split-lines (slurp data-src)))

(def data-regex #"(\d+)\-(\d+)\s(\w)\:\s(\w+)")

(defn transform-data [string]
  (let [[_ low high pattern password] (re-matches data-regex string)]
    [(Integer/parseInt low)
     (Integer/parseInt high)
     (re-pattern pattern)
     (str password)]))

(defn respects-sled-policy?
  [[low high pattern password]]
  (let [char-count (count (re-seq pattern password))]
    (<= low char-count high)))

(defn respects-tobogan-policy?
  [[low high pattern password]]
  (->> [low high]
       (map dec)
       (map #(get password %))
       (map str)
       (filter #(re-matches pattern %))
       (count)
       (= 1)))

(defn main []
  (let [data (map transform-data (load-data "input.txt"))]
    (println (count (filter respects-sled-policy? data)))
    (println (count (filter respects-tobogan-policy? data)))))
