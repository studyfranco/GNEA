CREATE DATABASE  IF NOT EXISTS `RNAlizer` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `RNAlizer`;
-- MySQL dump 10.16  Distrib 10.2.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: RNAlizer
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
-- Table structure for table `SampleNorm`
--

DROP TABLE IF EXISTS `SampleNorm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SampleNorm` (
  `IDSampleNorm` varchar(80) NOT NULL,
  `FKNormParam` int(15) unsigned zerofill NOT NULL,
  `FKSample` varchar(60) NOT NULL,
  `FKSampleAlign` varchar(65) NOT NULL,
  PRIMARY KEY (`IDSampleNorm`),
  KEY `IDSample` (`FKSample`),
  KEY `FKNormParam` (`FKNormParam`),
  KEY `IDSampleAlign` (`FKSampleAlign`),
  CONSTRAINT `SampleNorm_ibfk_1` FOREIGN KEY (`FKSample`) REFERENCES `Sample` (`IDSample`) ON UPDATE CASCADE,
  CONSTRAINT `SampleNorm_ibfk_2` FOREIGN KEY (`FKSampleAlign`) REFERENCES `SampleAlign` (`SampleAlign`) ON UPDATE CASCADE,
  CONSTRAINT `SampleNorm_ibfk_3` FOREIGN KEY (`FKNormParam`) REFERENCES `RunNormMethod` (`IDRun`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SampleNorm`
--

LOCK TABLES `SampleNorm` WRITE;
/*!40000 ALTER TABLE `SampleNorm` DISABLE KEYS */;
/*!40000 ALTER TABLE `SampleNorm` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-04-20 20:36:33
