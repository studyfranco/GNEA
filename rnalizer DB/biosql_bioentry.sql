CREATE DATABASE  IF NOT EXISTS `biosql` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `biosql`;
-- MySQL dump 10.16  Distrib 10.2.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: biosql
-- ------------------------------------------------------
-- Server version	10.2.14-MariaDB-10.2.14+maria~xenial

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bioentry`
--

DROP TABLE IF EXISTS `bioentry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bioentry` (
  `bioentry_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `biodatabase_id` int(10) unsigned NOT NULL,
  `taxon_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(40) NOT NULL,
  `accession` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `identifier` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `division` varchar(6) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `version` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`bioentry_id`),
  UNIQUE KEY `accession` (`accession`,`biodatabase_id`,`version`),
  UNIQUE KEY `identifier` (`identifier`,`biodatabase_id`),
  KEY `bioentry_name` (`name`),
  KEY `bioentry_db` (`biodatabase_id`),
  KEY `bioentry_tax` (`taxon_id`),
  CONSTRAINT `FKbiodatabase_bioentry` FOREIGN KEY (`biodatabase_id`) REFERENCES `biodatabase` (`biodatabase_id`),
  CONSTRAINT `FKtaxon_bioentry` FOREIGN KEY (`taxon_id`) REFERENCES `taxon` (`taxon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bioentry`
--

LOCK TABLES `bioentry` WRITE;
/*!40000 ALTER TABLE `bioentry` DISABLE KEYS */;
/*!40000 ALTER TABLE `bioentry` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-04-20 20:36:27
