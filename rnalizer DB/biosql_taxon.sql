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
-- Table structure for table `taxon`
--

DROP TABLE IF EXISTS `taxon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon` (
  `taxon_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ncbi_taxon_id` int(10) DEFAULT NULL,
  `parent_taxon_id` int(10) unsigned DEFAULT NULL,
  `node_rank` varchar(32) DEFAULT NULL,
  `genetic_code` tinyint(3) unsigned DEFAULT NULL,
  `mito_genetic_code` tinyint(3) unsigned DEFAULT NULL,
  `left_value` int(10) unsigned DEFAULT NULL,
  `right_value` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`taxon_id`),
  UNIQUE KEY `ncbi_taxon_id` (`ncbi_taxon_id`),
  UNIQUE KEY `left_value` (`left_value`),
  UNIQUE KEY `right_value` (`right_value`),
  KEY `taxparent` (`parent_taxon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon`
--

LOCK TABLES `taxon` WRITE;
/*!40000 ALTER TABLE `taxon` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-04-20 20:36:29
