CREATE DATABASE  IF NOT EXISTS `GOR` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `GOR`;
-- MySQL dump 10.16  Distrib 10.2.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: GOR
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
-- Table structure for table `map_metadata`
--

DROP TABLE IF EXISTS `map_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_metadata` (
  `map_name` varchar(80) NOT NULL,
  `source_name` varchar(80) NOT NULL,
  `source_url` varchar(255) NOT NULL,
  `source_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `map_metadata`
--

LOCK TABLES `map_metadata` WRITE;
/*!40000 ALTER TABLE `map_metadata` DISABLE KEYS */;
INSERT INTO `map_metadata` VALUES ('TERM','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('OBSOLETE','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('BPPARENTS','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('BPCHILDREN','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('BPANCESTOR','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('BPOFFSPRING','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('MFPARENTS','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('MFCHILDREN','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('MFANCESTOR','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('MFOFFSPRING','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('CCPARENTS','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('CCCHILDREN','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('CCANCESTOR','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01'),('CCOFFSPRING','Gene Ontology','ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/','2017-Nov01');
/*!40000 ALTER TABLE `map_metadata` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-04-20 20:36:37
