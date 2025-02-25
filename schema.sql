-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.3.31-MariaDB-0ubuntu0.20.04.1 - Ubuntu 20.04
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table okey_bot.7tv
DROP TABLE IF EXISTS `7tv`;
CREATE TABLE IF NOT EXISTS `7tv` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(25) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_7tv_channels` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.channels
DROP TABLE IF EXISTS `channels`;
CREATE TABLE IF NOT EXISTS `channels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `platform_id` varchar(255) NOT NULL,
  `login` varchar(25) NOT NULL,
  `prefix` varchar(15) NOT NULL DEFAULT '?',
  `pajbotAPI` varchar(500) DEFAULT NULL,
  `logging` tinyint(4) NOT NULL DEFAULT 1,
  `added` timestamp NOT NULL DEFAULT current_timestamp(),
  `parted` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `platform_id` (`platform_id`),
  KEY `login` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.confusables
DROP TABLE IF EXISTS `confusables`;
CREATE TABLE IF NOT EXISTS `confusables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char` varchar(50) NOT NULL DEFAULT '0',
  `conf` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `char` (`char`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.data
DROP TABLE IF EXISTS `data`;
CREATE TABLE IF NOT EXISTS `data` (
  `issued_commands` int(255) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.emotes
DROP TABLE IF EXISTS `emotes`;
CREATE TABLE IF NOT EXISTS `emotes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_login` varchar(25) NOT NULL,
  `channel_id` varchar(255) NOT NULL,
  `app_userid` varchar(500) DEFAULT NULL,
  `emote_id` varchar(500) NOT NULL,
  `reward_title` varchar(50) NOT NULL,
  `app` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_emotes_channels` (`channel_id`),
  CONSTRAINT `FK_emotes_channels` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`platform_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.errors
DROP TABLE IF EXISTS `errors`;
CREATE TABLE IF NOT EXISTS `errors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(500) NOT NULL DEFAULT '0',
  `data` text DEFAULT NULL,
  `error` text NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.floroaia_jokes
DROP TABLE IF EXISTS `floroaia_jokes`;
CREATE TABLE IF NOT EXISTS `floroaia_jokes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `joke` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.hugs
DROP TABLE IF EXISTS `hugs`;
CREATE TABLE IF NOT EXISTS `hugs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) NOT NULL,
  `count` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.messages
DROP TABLE IF EXISTS `messages`;
CREATE TABLE IF NOT EXISTS `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` varchar(255) NOT NULL,
  `channel_login` varchar(25) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `user_login` varchar(25) NOT NULL,
  `message` varchar(500) NOT NULL,
  `timestamp` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `channel_id` (`channel_id`),
  KEY `user_login` (`user_login`),
  KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.notify
DROP TABLE IF EXISTS `notify`;
CREATE TABLE IF NOT EXISTS `notify` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` varchar(255) NOT NULL,
  `channel_login` varchar(25) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `user_login` varchar(25) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_notify_channels` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.notify_data
DROP TABLE IF EXISTS `notify_data`;
CREATE TABLE IF NOT EXISTS `notify_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) NOT NULL,
  `login` varchar(25) NOT NULL,
  `live` tinyint(4) NOT NULL DEFAULT 0,
  `online_format` varchar(350) NOT NULL,
  `offline_format` varchar(350) NOT NULL,
  `title_format` varchar(350) NOT NULL,
  `category_format` varchar(350) NOT NULL,
  `discord_webhook` varchar(500) DEFAULT NULL,
  `discord_message` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_notify_data_channels` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.suggestions
DROP TABLE IF EXISTS `suggestions`;
CREATE TABLE IF NOT EXISTS `suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_login` varchar(25) NOT NULL,
  `author_id` varchar(255) NOT NULL,
  `status` varchar(200) NOT NULL DEFAULT 'Pending Review',
  `text` varchar(2000) DEFAULT NULL,
  `notes` varchar(2000) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

-- Dumping structure for table okey_bot.ttours
DROP TABLE IF EXISTS `ttours`;
CREATE TABLE IF NOT EXISTS `ttours` (
  `author` varchar(500) NOT NULL,
  `image` varchar(500) NOT NULL,
  `notes` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
