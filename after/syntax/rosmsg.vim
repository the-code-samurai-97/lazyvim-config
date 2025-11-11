" ROS message types and sensor_msgs types
syntax keyword rosmsgType int8 int16 int32 int64 uint8 uint16 uint32 uint64 float32 float64 string bool
syntax keyword rosmsgType Header Time Duration
syntax keyword rosmsgType geometry_msgs/Point geometry_msgs/Vector3 geometry_msgs/Quaternion geometry_msgs/Pose geometry_msgs/PoseStamped
syntax keyword rosmsgType sensor_msgs/Image sensor_msgs/Imu sensor_msgs/JointState sensor_msgs/LaserScan sensor_msgs/PointCloud sensor_msgs/PointCloud2 sensor_msgs/Range sensor_msgs/NavSatFix
syntax keyword rosmsgType std_msgs/Bool std_msgs/Byte std_msgs/Char std_msgs/ColorRGBA std_msgs/Duration std_msgs/Empty std_msgs/Float32 std_msgs/Float64 std_msgs/Header std_msgs/Int16 std_msgs/Int32 std_msgs/Int64 std_msgs/Int8 std_msgs/MultiArrayDimension std_msgs/MultiArrayLayout std_msgs/String std_msgs/Time std_msgs/UInt16 std_msgs/UInt32 std_msgs/UInt64 std_msgs/UInt8

highlight link rosmsgType Type

" Comments
syntax match rosmsgComment "#.*$"
highlight link rosmsgComment Comment

" Constants (true/false)
syntax keyword rosmsgConst true false
highlight link rosmsgConst Boolean
