CREATE TABLE IF NOT EXISTS `User` (
`id` INTEGER PRIMARY KEY AUTOINCREMENT,
`name` varchar(50) NOT NULL DEFAULT '',
`sex` varchar(4) DEFAULT NULL,
`age` tinyint(4) DEFAULT '0',
`car_id` int(11)
);

CREATE TABLE IF NOT EXISTS `Car` (
`id` INTEGER PRIMARY KEY AUTOINCREMENT,
`name` varchar(11) NOT NULL DEFAULT '',
`price` double DEFAULT '0'
);
