-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           10.4.11-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              10.3.0.5771
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Copiando estrutura do banco de dados para redm
CREATE DATABASE IF NOT EXISTS `redm` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `redm`;

-- Copiando estrutura para tabela redm.horses
CREATE TABLE IF NOT EXISTS `horses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charid` int(11) NOT NULL,
  `model` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `components` text NOT NULL DEFAULT '{}',
  PRIMARY KEY (`id`),
  KEY `FK_horses_characters` (`charid`),
  CONSTRAINT `FK_horses_characters` FOREIGN KEY (`charid`) REFERENCES `characters` (`charid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela redm.horses: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `horses` DISABLE KEYS */;
INSERT IGNORE INTO `horses` (`id`, `charid`, `model`, `name`, `components`) VALUES
	(15, 84, 'A_C_Horse_AmericanStandardbred_Buckskin', 'CavaloRuim', '["0x106961A8","0x3278996D","0x67AF7302","0x1D4EDB88","0x130E341A","0x12DBBBAF","0x333CDC06","0x12F0DF9F"]'),
	(16, 84, 'A_C_HORSE_MORGAN_FLAXENCHESTNUT', 'CavaloBom', '["0x14168240","0x19C5E80C","0x587DD49F","0x20AA8620","0x14098229","0x1BB5EAA1","0x2A28C8BE","0x12F0DF9F"]');
/*!40000 ALTER TABLE `horses` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
