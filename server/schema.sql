-- phpMyAdmin SQL Dump
-- version 3.3.10.4
-- http://www.phpmyadmin.net
--
-- Host: mysql.pseudoglossa.gr
-- Generation Time: Jan 29, 2013 at 10:53 PM
-- Server version: 5.1.39
-- PHP Version: 5.2.17

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `pseudoglossa`
--

-- --------------------------------------------------------

--
-- Table structure for table `algorithms`
--

CREATE TABLE IF NOT EXISTS `algorithms` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userId` int(11) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(255) NOT NULL,
  `body` text,
  `inputFile` text,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=17783 ;

-- --------------------------------------------------------

--
-- Table structure for table `algorithms-global_tags`
--

CREATE TABLE IF NOT EXISTS `algorithms-global_tags` (
  `algorithmId` int(11) unsigned NOT NULL,
  `globalTagId` int(11) unsigned NOT NULL,
  PRIMARY KEY (`algorithmId`,`globalTagId`),
  KEY `globalTagId` (`globalTagId`),
  KEY `algorithmId` (`algorithmId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `algorithms-user_tags`
--

CREATE TABLE IF NOT EXISTS `algorithms-user_tags` (
  `algorithmId` int(11) unsigned NOT NULL,
  `userTagId` int(11) unsigned NOT NULL,
  PRIMARY KEY (`algorithmId`,`userTagId`),
  KEY `userTagId` (`userTagId`),
  KEY `algorithmId` (`algorithmId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `global_tags`
--

CREATE TABLE IF NOT EXISTS `global_tags` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `order` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=23 ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL,
  `firstName` varchar(64) DEFAULT NULL,
  `lastName` varchar(64) DEFAULT NULL,
  `email` varchar(128) NOT NULL,
  `password` varchar(32) NOT NULL,
  `dateRegistered` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `settings` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2466 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_tags`
--

CREATE TABLE IF NOT EXISTS `user_tags` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userId` int(11) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=269 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `algorithms`
--
ALTER TABLE `algorithms`
  ADD CONSTRAINT `algorithms_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `algorithms-global_tags`
--
ALTER TABLE `algorithms-global_tags`
  ADD CONSTRAINT `algorithms@002dglobal_tags_ibfk_1` FOREIGN KEY (`algorithmId`) REFERENCES `algorithms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `algorithms@002dglobal_tags_ibfk_2` FOREIGN KEY (`globalTagId`) REFERENCES `global_tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `algorithms-user_tags`
--
ALTER TABLE `algorithms-user_tags`
  ADD CONSTRAINT `algorithms@002duser_tags_ibfk_1` FOREIGN KEY (`algorithmId`) REFERENCES `algorithms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `algorithms@002duser_tags_ibfk_2` FOREIGN KEY (`userTagId`) REFERENCES `user_tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_tags`
--
ALTER TABLE `user_tags`
  ADD CONSTRAINT `user_tags_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

