CREATE TABLE IF NOT EXISTS `User` (
`id` int(11) PRIMARY KEY,
`name` varchar(50) NOT NULL DEFAULT '',
`sex` varchar(4) DEFAULT NULL,
`age` tinyint(4) DEFAULT '0'
);

CREATE TABLE IF NOT EXISTS `Car` (
`id` int(11) PRIMARY KEY,
`name` varchar(11) NOT NULL DEFAULT '',
`price` double DEFAULT '0'
);
