-- phpMyAdmin SQL Dump
-- version 3.3.7deb6
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 27. November 2011 um 14:07
-- Server Version: 5.1.49
-- PHP-Version: 5.3.3-7+squeeze3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Datenbank: `dqc`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `anz_zeichen`
--

CREATE TABLE IF NOT EXISTS `anz_zeichen` (
  `anz` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `ben_benutzer`
--

CREATE TABLE IF NOT EXISTS `ben_benutzer` (
  `ben_id` int(11) NOT NULL AUTO_INCREMENT,
  `ben_user` varchar(50) NOT NULL,
  `ben_session` varchar(100) NOT NULL,
  `ben_pw` varchar(100) NOT NULL,
  `ben_dat` datetime NOT NULL,
  `ben_admin` smallint(1) NOT NULL,
  `ben_status` varchar(20) NOT NULL,
  `ben_hidemenu` int(11) NOT NULL,
  `ben_kick` int(11) NOT NULL,
  `ben_punkte` int(11) NOT NULL,
  `ben_potd` int(11) NOT NULL,
  `ben_news` int(11) NOT NULL,
  `ben_flagge` int(11) NOT NULL,
  `ben_lastdate` date NOT NULL,
  `verteidigung` int(11) NOT NULL,
  PRIMARY KEY (`ben_id`),
  UNIQUE KEY `ben_user` (`ben_user`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=27 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `log_login`
--

CREATE TABLE IF NOT EXISTS `log_login` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `ben_fk` varchar(100) NOT NULL,
  `log_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `refresh` int(1) NOT NULL,
  PRIMARY KEY (`log_id`),
  UNIQUE KEY `ben_fk` (`ben_fk`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1199 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `not_notiz`
--

CREATE TABLE IF NOT EXISTS `not_notiz` (
  `not_id` int(11) NOT NULL AUTO_INCREMENT,
  `ben_fk` int(11) NOT NULL,
  `not_notiz` varchar(250) NOT NULL,
  `not_date` datetime NOT NULL,
  PRIMARY KEY (`not_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=146 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `tex_text`
--

CREATE TABLE IF NOT EXISTS `tex_text` (
  `tex_id` int(11) NOT NULL AUTO_INCREMENT,
  `ben_fk` varchar(20) NOT NULL,
  `tex_text` text NOT NULL,
  `tex_dat` datetime NOT NULL,
  `tex_von` varchar(30) NOT NULL,
  `tex_an` varchar(30) NOT NULL,
  `tex_kat` int(11) NOT NULL,
  PRIMARY KEY (`tex_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2359 ;
