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


-- Copiando estrutura do banco de dados para redemrp
CREATE DATABASE IF NOT EXISTS `redemrp` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `redemrp`;

-- Copiando estrutura para tabela redemrp.horses
CREATE TABLE IF NOT EXISTS `horses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(40) NOT NULL,
  `charid` int(11) NOT NULL,
  `selected` int(11) NOT NULL DEFAULT 0,
  `model` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `components` text NOT NULL DEFAULT '{}',
  PRIMARY KEY (`id`),
  KEY `FK_horses_characters` (`charid`)
);

-- Copiando dados para a tabela redemrp.horses: ~3 rows (aproximadamente)
/*!40000 ALTER TABLE `horses` DISABLE KEYS */;
INSERT IGNORE INTO `horses` (`id`, `identifier`, `charid`, `selected`, `model`, `name`, `components`) VALUES
	(13, 'steam:11000010596ee06', 1, 0, 'A_C_Horse_KentuckySaddle_Grey', 'Nome', '{}'),
	(25, 'steam:11000010596ee06', 1, 0, 'A_C_Horse_Belgian_MealyChestnut', 'kkk', '{}'),
	(26, 'steam:11000010596ee06', 1, 1, 'A_C_Horse_Andalusian_DarkBay', 'kk', '{}');
/*!40000 ALTER TABLE `horses` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
