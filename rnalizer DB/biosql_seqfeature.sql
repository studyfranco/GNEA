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
-- Table structure for table `seqfeature`
--

DROP TABLE IF EXISTS `seqfeature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seqfeature` (
  `seqfeature_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bioentry_id` int(10) unsigned NOT NULL,
  `type_term_id` int(10) unsigned NOT NULL,
  `source_term_id` int(10) unsigned NOT NULL,
  `display_name` varchar(64) DEFAULT NULL,
  `rank` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`seqfeature_id`),
  UNIQUE KEY `bioentry_id` (`bioentry_id`,`type_term_id`,`source_term_id`,`rank`),
  KEY `seqfeature_trm` (`type_term_id`),
  KEY `seqfeature_fsrc` (`source_term_id`),
  CONSTRAINT `FKbioentry_seqfeature` FOREIGN KEY (`bioentry_id`) REFERENCES `bioentry` (`bioentry_id`) ON DELETE CASCADE,
  CONSTRAINT `FKsourceterm_seqfeature` FOREIGN KEY (`source_term_id`) REFERENCES `term` (`term_id`),
  CONSTRAINT `FKterm_seqfeature` FOREIGN KEY (`type_term_id`) REFERENCES `term` (`term_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seqfeature`
--

LOCK TABLES `seqfeature` WRITE;
/*!40000 ALTER TABLE `seqfeature` DISABLE KEYS */;
/*!40000 ALTER TABLE `seqfeature` ENABLE KEYS */;
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
