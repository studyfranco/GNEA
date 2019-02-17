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
-- Table structure for table `RunNormMethod`
--

DROP TABLE IF EXISTS `RunNormMethod`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RunNormMethod` (
  `IDRun` int(15) unsigned zerofill NOT NULL,
  `IDRunNorm` int(10) unsigned zerofill NOT NULL,
  `FKParamNorm` int(5) unsigned zerofill NOT NULL,
  `FKReferenceAlign` varchar(65) NOT NULL,
  PRIMARY KEY (`IDRun`),
  KEY `FKParamNorm` (`FKParamNorm`),
  KEY `Reference` (`FKReferenceAlign`),
  KEY `IDRunNorm` (`IDRunNorm`),
  CONSTRAINT `RunNormMethod_ibfk_1` FOREIGN KEY (`FKParamNorm`) REFERENCES `NormParam` (`IDNorm`) ON UPDATE CASCADE,
  CONSTRAINT `RunNormMethod_ibfk_2` FOREIGN KEY (`FKReferenceAlign`) REFERENCES `SampleAlign` (`SampleAlign`) ON UPDATE CASCADE,
  CONSTRAINT `RunNormMethod_ibfk_3` FOREIGN KEY (`IDRunNorm`) REFERENCES `RunNorm` (`IDRunNorm`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RunNormMethod`
--

LOCK TABLES `RunNormMethod` WRITE;
/*!40000 ALTER TABLE `RunNormMethod` DISABLE KEYS */;
/*!40000 ALTER TABLE `RunNormMethod` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-04-20 20:36:31
