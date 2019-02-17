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
-- Table structure for table `seqfeature_path`
--

DROP TABLE IF EXISTS `seqfeature_path`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seqfeature_path` (
  `object_seqfeature_id` int(10) unsigned NOT NULL,
  `subject_seqfeature_id` int(10) unsigned NOT NULL,
  `term_id` int(10) unsigned NOT NULL,
  `distance` int(10) unsigned DEFAULT NULL,
  UNIQUE KEY `object_seqfeature_id` (`object_seqfeature_id`,`subject_seqfeature_id`,`term_id`,`distance`),
  KEY `seqfeaturepath_trm` (`term_id`),
  KEY `seqfeaturepath_child` (`subject_seqfeature_id`),
  CONSTRAINT `FKchildfeat_seqfeatpath` FOREIGN KEY (`subject_seqfeature_id`) REFERENCES `seqfeature` (`seqfeature_id`) ON DELETE CASCADE,
  CONSTRAINT `FKparentfeat_seqfeatpath` FOREIGN KEY (`object_seqfeature_id`) REFERENCES `seqfeature` (`seqfeature_id`) ON DELETE CASCADE,
  CONSTRAINT `FKterm_seqfeatpath` FOREIGN KEY (`term_id`) REFERENCES `term` (`term_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seqfeature_path`
--

LOCK TABLES `seqfeature_path` WRITE;
/*!40000 ALTER TABLE `seqfeature_path` DISABLE KEYS */;
/*!40000 ALTER TABLE `seqfeature_path` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-04-20 20:36:28
