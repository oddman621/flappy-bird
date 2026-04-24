(declare-project
  :name "flappy-bird"
  :description ```Flappy Bird with Janet ```
  :version "0.0.0"
  :dependencies ["jaylib"])

(declare-executable
  :name "flappy-bird"
  :entry "flappy-bird/init.janet")

# cmd창을 띄우게 하고 싶지 않을 경우, declare-executable에 다음을 추가
# :ldflags ["-mwindows"] # MinGW GCC 를 사용할 경우
# :ldflags ["/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup"] # MSVC를 사용할 경우