CREATE TABLE `account_deletions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `diaspora_handle` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `aspect_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `aspect_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_aspect_memberships_on_aspect_id_and_contact_id` (`aspect_id`,`contact_id`),
  KEY `index_aspect_memberships_on_aspect_id` (`aspect_id`),
  KEY `index_aspect_memberships_on_contact_id` (`contact_id`),
  CONSTRAINT `aspect_memberships_aspect_id_fk` FOREIGN KEY (`aspect_id`) REFERENCES `aspects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `aspect_memberships_contact_id_fk` FOREIGN KEY (`contact_id`) REFERENCES `contacts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `aspect_visibilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shareable_id` int(11) NOT NULL,
  `aspect_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `shareable_type` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT 'Post',
  PRIMARY KEY (`id`),
  KEY `index_aspect_visibilities_on_aspect_id` (`aspect_id`),
  KEY `shareable_and_aspect_id` (`shareable_id`,`shareable_type`,`aspect_id`),
  KEY `index_aspect_visibilities_on_shareable_id_and_shareable_type` (`shareable_id`,`shareable_type`),
  CONSTRAINT `aspect_visibilities_aspect_id_fk` FOREIGN KEY (`aspect_id`) REFERENCES `aspects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `aspects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `contacts_visible` tinyint(1) NOT NULL DEFAULT '1',
  `order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_aspects_on_user_id_and_contacts_visible` (`user_id`,`contacts_visible`),
  KEY `index_aspects_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` text COLLATE utf8_bin NOT NULL,
  `commentable_id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  `guid` varchar(255) COLLATE utf8_bin NOT NULL,
  `author_signature` text COLLATE utf8_bin,
  `parent_author_signature` text COLLATE utf8_bin,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `likes_count` int(11) NOT NULL DEFAULT '0',
  `commentable_type` varchar(60) COLLATE utf8_bin NOT NULL DEFAULT 'Post',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_comments_on_guid` (`guid`),
  KEY `index_comments_on_person_id` (`author_id`),
  KEY `index_comments_on_commentable_id_and_commentable_type` (`commentable_id`,`commentable_type`),
  CONSTRAINT `comments_author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sharing` tinyint(1) NOT NULL DEFAULT '0',
  `receiving` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_contacts_on_user_id_and_person_id` (`user_id`,`person_id`),
  KEY `index_contacts_on_person_id` (`person_id`),
  CONSTRAINT `contacts_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `conversation_visibilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `conversation_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `unread` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_conversation_visibilities_usefully` (`conversation_id`,`person_id`),
  KEY `index_conversation_visibilities_on_conversation_id` (`conversation_id`),
  KEY `index_conversation_visibilities_on_person_id` (`person_id`),
  CONSTRAINT `conversation_visibilities_conversation_id_fk` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `conversation_visibilities_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `guid` varchar(255) COLLATE utf8_bin NOT NULL,
  `author_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `conversations_author_id_fk` (`author_id`),
  CONSTRAINT `conversations_author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `invitation_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `invitations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` text COLLATE utf8_bin,
  `sender_id` int(11) DEFAULT NULL,
  `recipient_id` int(11) DEFAULT NULL,
  `aspect_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `service` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `identifier` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `admin` tinyint(1) DEFAULT '0',
  `language` varchar(255) COLLATE utf8_bin DEFAULT 'en',
  PRIMARY KEY (`id`),
  KEY `index_invitations_on_aspect_id` (`aspect_id`),
  KEY `index_invitations_on_recipient_id` (`recipient_id`),
  KEY `index_invitations_on_sender_id` (`sender_id`),
  CONSTRAINT `invitations_recipient_id_fk` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `invitations_sender_id_fk` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `positive` tinyint(1) DEFAULT '1',
  `target_id` int(11) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `guid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `author_signature` text COLLATE utf8_bin,
  `parent_author_signature` text COLLATE utf8_bin,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `target_type` varchar(60) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_likes_on_guid` (`guid`),
  UNIQUE KEY `index_likes_on_target_id_and_author_id_and_target_type` (`target_id`,`author_id`,`target_type`),
  KEY `likes_author_id_fk` (`author_id`),
  KEY `index_likes_on_post_id` (`target_id`),
  CONSTRAINT `likes_author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `lat` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `lng` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `status_message_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `mentions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mentions_on_person_id_and_post_id` (`person_id`,`post_id`),
  KEY `index_mentions_on_person_id` (`person_id`),
  KEY `index_mentions_on_post_id` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `conversation_id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  `guid` varchar(255) COLLATE utf8_bin NOT NULL,
  `text` text COLLATE utf8_bin NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `author_signature` text COLLATE utf8_bin,
  `parent_author_signature` text COLLATE utf8_bin,
  PRIMARY KEY (`id`),
  KEY `index_messages_on_author_id` (`author_id`),
  KEY `messages_conversation_id_fk` (`conversation_id`),
  CONSTRAINT `messages_author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_conversation_id_fk` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `notification_actors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_notification_actors_on_notification_id_and_person_id` (`notification_id`,`person_id`),
  KEY `index_notification_actors_on_notification_id` (`notification_id`),
  KEY `index_notification_actors_on_person_id` (`person_id`),
  CONSTRAINT `notification_actors_notification_id_fk` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_type` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `recipient_id` int(11) NOT NULL,
  `unread` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `type` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_notifications_on_recipient_id` (`recipient_id`),
  KEY `index_notifications_on_target_id` (`target_id`),
  KEY `index_notifications_on_target_type_and_target_id` (`target_type`,`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `o_embed_caches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(1024) COLLATE utf8_bin NOT NULL,
  `data` text COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_o_embed_caches_on_url` (`url`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `open_graph_caches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ob_type` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `image` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `description` text COLLATE utf8_bin,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `participations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `target_type` varchar(60) COLLATE utf8_bin NOT NULL,
  `author_id` int(11) DEFAULT NULL,
  `author_signature` text COLLATE utf8_bin,
  `parent_author_signature` text COLLATE utf8_bin,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_participations_on_guid` (`guid`),
  KEY `index_participations_on_target_id_and_target_type_and_author_id` (`target_id`,`target_type`,`author_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guid` varchar(255) COLLATE utf8_bin NOT NULL,
  `url` text COLLATE utf8_bin NOT NULL,
  `diaspora_handle` varchar(255) COLLATE utf8_bin NOT NULL,
  `serialized_public_key` text COLLATE utf8_bin NOT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `closed_account` tinyint(1) DEFAULT '0',
  `fetch_status` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_people_on_diaspora_handle` (`diaspora_handle`),
  UNIQUE KEY `index_people_on_guid` (`guid`),
  UNIQUE KEY `index_people_on_owner_id` (`owner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tmp_old_id` int(11) DEFAULT NULL,
  `author_id` int(11) NOT NULL,
  `public` tinyint(1) NOT NULL DEFAULT '0',
  `diaspora_handle` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `guid` varchar(255) COLLATE utf8_bin NOT NULL,
  `pending` tinyint(1) NOT NULL DEFAULT '0',
  `text` text COLLATE utf8_bin,
  `remote_photo_path` text COLLATE utf8_bin,
  `remote_photo_name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `random_string` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `processed_image` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `unprocessed_image` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `status_message_guid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `comments_count` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_photos_on_status_message_guid` (`status_message_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `pods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ssl` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `poll_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `answer` varchar(255) COLLATE utf8_bin NOT NULL,
  `poll_id` int(11) NOT NULL,
  `guid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `vote_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_poll_answers_on_poll_id` (`poll_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `poll_participations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `poll_answer_id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  `poll_id` int(11) NOT NULL,
  `guid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `author_signature` text COLLATE utf8_bin,
  `parent_author_signature` text COLLATE utf8_bin,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_poll_participations_on_poll_id` (`poll_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `polls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question` varchar(255) COLLATE utf8_bin NOT NULL,
  `status_message_id` int(11) NOT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `guid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_polls_on_status_message_id` (`status_message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_id` int(11) NOT NULL,
  `public` tinyint(1) NOT NULL DEFAULT '0',
  `diaspora_handle` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `guid` varchar(255) COLLATE utf8_bin NOT NULL,
  `pending` tinyint(1) NOT NULL DEFAULT '0',
  `type` varchar(40) COLLATE utf8_bin NOT NULL,
  `text` text COLLATE utf8_bin,
  `remote_photo_path` text COLLATE utf8_bin,
  `remote_photo_name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `random_string` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `processed_image` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `unprocessed_image` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `object_url` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `image_url` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `image_height` int(11) DEFAULT NULL,
  `image_width` int(11) DEFAULT NULL,
  `provider_display_name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `actor_url` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `objectId` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `root_guid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `status_message_guid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `likes_count` int(11) DEFAULT '0',
  `comments_count` int(11) DEFAULT '0',
  `o_embed_cache_id` int(11) DEFAULT NULL,
  `reshares_count` int(11) DEFAULT '0',
  `interacted_at` datetime DEFAULT NULL,
  `frame_name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `favorite` tinyint(1) DEFAULT '0',
  `facebook_id` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `tweet_id` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `open_graph_cache_id` int(11) DEFAULT NULL,
  `tumblr_ids` text COLLATE utf8_bin,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_posts_on_guid` (`guid`),
  UNIQUE KEY `index_posts_on_author_id_and_root_guid` (`author_id`,`root_guid`),
  KEY `index_posts_on_person_id` (`author_id`),
  KEY `index_posts_on_id_and_type_and_created_at` (`id`,`type`,`created_at`),
  KEY `index_posts_on_root_guid` (`root_guid`),
  KEY `index_posts_on_status_message_guid_and_pending` (`status_message_guid`,`pending`),
  KEY `index_posts_on_status_message_guid` (`status_message_guid`),
  KEY `index_posts_on_tweet_id` (`tweet_id`),
  KEY `index_posts_on_type_and_pending_and_id` (`type`,`pending`,`id`),
  CONSTRAINT `posts_author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `diaspora_handle` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `first_name` varchar(127) COLLATE utf8_bin DEFAULT NULL,
  `last_name` varchar(127) COLLATE utf8_bin DEFAULT NULL,
  `image_url` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `image_url_small` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `image_url_medium` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `gender` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `bio` text COLLATE utf8_bin,
  `searchable` tinyint(1) NOT NULL DEFAULT '1',
  `person_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `location` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `full_name` varchar(70) COLLATE utf8_bin DEFAULT NULL,
  `nsfw` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_profiles_on_full_name_and_searchable` (`full_name`,`searchable`),
  KEY `index_profiles_on_full_name` (`full_name`),
  KEY `index_profiles_on_person_id` (`person_id`),
  CONSTRAINT `profiles_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `rails_admin_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` text COLLATE utf8_bin,
  `username` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `item` int(11) DEFAULT NULL,
  `table` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `month` smallint(6) DEFAULT NULL,
  `year` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rails_admin_histories` (`item`,`table`,`month`,`year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `item_type` varchar(255) COLLATE utf8_bin NOT NULL,
  `reviewed` tinyint(1) DEFAULT '0',
  `text` text COLLATE utf8_bin,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_post_reports_on_post_id` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_bin NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(127) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) NOT NULL,
  `uid` varchar(127) COLLATE utf8_bin DEFAULT NULL,
  `access_token` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `access_secret` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `nickname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_services_on_type_and_uid` (`type`,`uid`),
  KEY `index_services_on_user_id` (`user_id`),
  CONSTRAINT `services_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `share_visibilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shareable_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `hidden` tinyint(1) NOT NULL DEFAULT '0',
  `contact_id` int(11) NOT NULL,
  `shareable_type` varchar(60) COLLATE utf8_bin NOT NULL DEFAULT 'Post',
  PRIMARY KEY (`id`),
  KEY `index_post_visibilities_on_contact_id` (`contact_id`),
  KEY `shareable_and_contact_id` (`shareable_id`,`shareable_type`,`contact_id`),
  KEY `shareable_and_hidden_and_contact_id` (`shareable_id`,`shareable_type`,`hidden`,`contact_id`),
  KEY `index_post_visibilities_on_post_id` (`shareable_id`),
  CONSTRAINT `post_visibilities_contact_id_fk` FOREIGN KEY (`contact_id`) REFERENCES `contacts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `simple_captcha_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(40) COLLATE utf8_bin DEFAULT NULL,
  `value` varchar(6) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `tag_followings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tag_followings_on_tag_id_and_user_id` (`tag_id`,`user_id`),
  KEY `index_tag_followings_on_tag_id` (`tag_id`),
  KEY `index_tag_followings_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `taggable_type` varchar(127) COLLATE utf8_bin DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(127) COLLATE utf8_bin DEFAULT NULL,
  `context` varchar(127) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_taggings_uniquely` (`taggable_id`,`taggable_type`,`tag_id`),
  KEY `index_taggings_on_created_at` (`created_at`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type_and_context` (`taggable_id`,`taggable_type`,`context`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `taggings_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email_type` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `serialized_private_key` text COLLATE utf8_bin,
  `getting_started` tinyint(1) NOT NULL DEFAULT '1',
  `disable_mail` tinyint(1) NOT NULL DEFAULT '0',
  `language` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  `invitation_token` varchar(60) COLLATE utf8_bin DEFAULT NULL,
  `invitation_sent_at` datetime DEFAULT NULL,
  `reset_password_token` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `invitation_service` varchar(127) COLLATE utf8_bin DEFAULT NULL,
  `invitation_identifier` varchar(127) COLLATE utf8_bin DEFAULT NULL,
  `invitation_limit` int(11) DEFAULT NULL,
  `invited_by_id` int(11) DEFAULT NULL,
  `invited_by_type` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `authentication_token` varchar(30) COLLATE utf8_bin DEFAULT NULL,
  `unconfirmed_email` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `confirm_email_token` varchar(30) COLLATE utf8_bin DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `show_community_spotlight_in_stream` tinyint(1) NOT NULL DEFAULT '1',
  `auto_follow_back` tinyint(1) DEFAULT '0',
  `auto_follow_back_aspect_id` int(11) DEFAULT NULL,
  `hidden_shareables` text COLLATE utf8_bin,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `last_seen` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_authentication_token` (`authentication_token`),
  UNIQUE KEY `index_users_on_invitation_service_and_invitation_identifier` (`invitation_service`,`invitation_identifier`),
  UNIQUE KEY `index_users_on_username` (`username`),
  KEY `index_users_on_email` (`email`),
  KEY `index_users_on_invitation_token` (`invitation_token`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO schema_migrations (version) VALUES ('0');

INSERT INTO schema_migrations (version) VALUES ('20110105051803');

INSERT INTO schema_migrations (version) VALUES ('20110119060243');

INSERT INTO schema_migrations (version) VALUES ('20110119221746');

INSERT INTO schema_migrations (version) VALUES ('20110120181553');

INSERT INTO schema_migrations (version) VALUES ('20110120182100');

INSERT INTO schema_migrations (version) VALUES ('20110123210746');

INSERT INTO schema_migrations (version) VALUES ('20110125190034');

INSERT INTO schema_migrations (version) VALUES ('20110126015407');

INSERT INTO schema_migrations (version) VALUES ('20110126200714');

INSERT INTO schema_migrations (version) VALUES ('20110126225202');

INSERT INTO schema_migrations (version) VALUES ('20110126232040');

INSERT INTO schema_migrations (version) VALUES ('20110127000931');

INSERT INTO schema_migrations (version) VALUES ('20110127000953');

INSERT INTO schema_migrations (version) VALUES ('20110130072907');

INSERT INTO schema_migrations (version) VALUES ('20110202015222');

INSERT INTO schema_migrations (version) VALUES ('20110209204702');

INSERT INTO schema_migrations (version) VALUES ('20110211021926');

INSERT INTO schema_migrations (version) VALUES ('20110211204804');

INSERT INTO schema_migrations (version) VALUES ('20110213052742');

INSERT INTO schema_migrations (version) VALUES ('20110217044519');

INSERT INTO schema_migrations (version) VALUES ('20110225190919');

INSERT INTO schema_migrations (version) VALUES ('20110228180709');

INSERT INTO schema_migrations (version) VALUES ('20110228201109');

INSERT INTO schema_migrations (version) VALUES ('20110228220810');

INSERT INTO schema_migrations (version) VALUES ('20110228233419');

INSERT INTO schema_migrations (version) VALUES ('20110301014507');

INSERT INTO schema_migrations (version) VALUES ('20110301202619');

INSERT INTO schema_migrations (version) VALUES ('20110311000150');

INSERT INTO schema_migrations (version) VALUES ('20110311183826');

INSERT INTO schema_migrations (version) VALUES ('20110311220249');

INSERT INTO schema_migrations (version) VALUES ('20110313015438');

INSERT INTO schema_migrations (version) VALUES ('20110314043119');

INSERT INTO schema_migrations (version) VALUES ('20110317222802');

INSERT INTO schema_migrations (version) VALUES ('20110318000734');

INSERT INTO schema_migrations (version) VALUES ('20110318012008');

INSERT INTO schema_migrations (version) VALUES ('20110319005509');

INSERT INTO schema_migrations (version) VALUES ('20110319172136');

INSERT INTO schema_migrations (version) VALUES ('20110321205715');

INSERT INTO schema_migrations (version) VALUES ('20110323213655');

INSERT INTO schema_migrations (version) VALUES ('20110328175936');

INSERT INTO schema_migrations (version) VALUES ('20110328202414');

INSERT INTO schema_migrations (version) VALUES ('20110330175950');

INSERT INTO schema_migrations (version) VALUES ('20110330230206');

INSERT INTO schema_migrations (version) VALUES ('20110331004720');

INSERT INTO schema_migrations (version) VALUES ('20110405170101');

INSERT INTO schema_migrations (version) VALUES ('20110405171412');

INSERT INTO schema_migrations (version) VALUES ('20110406202932');

INSERT INTO schema_migrations (version) VALUES ('20110406203720');

INSERT INTO schema_migrations (version) VALUES ('20110421120744');

INSERT INTO schema_migrations (version) VALUES ('20110507212759');

INSERT INTO schema_migrations (version) VALUES ('20110513175000');

INSERT INTO schema_migrations (version) VALUES ('20110514182918');

INSERT INTO schema_migrations (version) VALUES ('20110517180148');

INSERT INTO schema_migrations (version) VALUES ('20110518010050');

INSERT INTO schema_migrations (version) VALUES ('20110518184453');

INSERT INTO schema_migrations (version) VALUES ('20110518222303');

INSERT INTO schema_migrations (version) VALUES ('20110524184202');

INSERT INTO schema_migrations (version) VALUES ('20110525213325');

INSERT INTO schema_migrations (version) VALUES ('20110527135552');

INSERT INTO schema_migrations (version) VALUES ('20110601083310');

INSERT INTO schema_migrations (version) VALUES ('20110601091059');

INSERT INTO schema_migrations (version) VALUES ('20110603181015');

INSERT INTO schema_migrations (version) VALUES ('20110603212633');

INSERT INTO schema_migrations (version) VALUES ('20110603233202');

INSERT INTO schema_migrations (version) VALUES ('20110604012703');

INSERT INTO schema_migrations (version) VALUES ('20110604204533');

INSERT INTO schema_migrations (version) VALUES ('20110606192307');

INSERT INTO schema_migrations (version) VALUES ('20110623210918');

INSERT INTO schema_migrations (version) VALUES ('20110701215925');

INSERT INTO schema_migrations (version) VALUES ('20110705003445');

INSERT INTO schema_migrations (version) VALUES ('20110707221112');

INSERT INTO schema_migrations (version) VALUES ('20110707234802');

INSERT INTO schema_migrations (version) VALUES ('20110710102747');

INSERT INTO schema_migrations (version) VALUES ('20110729045734');

INSERT INTO schema_migrations (version) VALUES ('20110730173137');

INSERT INTO schema_migrations (version) VALUES ('20110730173443');

INSERT INTO schema_migrations (version) VALUES ('20110812175614');

INSERT INTO schema_migrations (version) VALUES ('20110815210933');

INSERT INTO schema_migrations (version) VALUES ('20110816061820');

INSERT INTO schema_migrations (version) VALUES ('20110818212541');

INSERT INTO schema_migrations (version) VALUES ('20110830170929');

INSERT INTO schema_migrations (version) VALUES ('20110907205720');

INSERT INTO schema_migrations (version) VALUES ('20110911213207');

INSERT INTO schema_migrations (version) VALUES ('20110924112840');

INSERT INTO schema_migrations (version) VALUES ('20110926120220');

INSERT INTO schema_migrations (version) VALUES ('20110930182048');

INSERT INTO schema_migrations (version) VALUES ('20111002013921');

INSERT INTO schema_migrations (version) VALUES ('20111003232053');

INSERT INTO schema_migrations (version) VALUES ('20111011193702');

INSERT INTO schema_migrations (version) VALUES ('20111011194702');

INSERT INTO schema_migrations (version) VALUES ('20111011195702');

INSERT INTO schema_migrations (version) VALUES ('20111012215141');

INSERT INTO schema_migrations (version) VALUES ('20111016145626');

INSERT INTO schema_migrations (version) VALUES ('20111018010003');

INSERT INTO schema_migrations (version) VALUES ('20111019013244');

INSERT INTO schema_migrations (version) VALUES ('20111021184041');

INSERT INTO schema_migrations (version) VALUES ('20111023230730');

INSERT INTO schema_migrations (version) VALUES ('20111026173547');

INSERT INTO schema_migrations (version) VALUES ('20111101202137');

INSERT INTO schema_migrations (version) VALUES ('20111103184050');

INSERT INTO schema_migrations (version) VALUES ('20111109023618');

INSERT INTO schema_migrations (version) VALUES ('20111111025358');

INSERT INTO schema_migrations (version) VALUES ('20111114173111');

INSERT INTO schema_migrations (version) VALUES ('20111207230506');

INSERT INTO schema_migrations (version) VALUES ('20111207233503');

INSERT INTO schema_migrations (version) VALUES ('20111211213438');

INSERT INTO schema_migrations (version) VALUES ('20111217042006');

INSERT INTO schema_migrations (version) VALUES ('20120107220942');

INSERT INTO schema_migrations (version) VALUES ('20120114191018');

INSERT INTO schema_migrations (version) VALUES ('20120127235102');

INSERT INTO schema_migrations (version) VALUES ('20120202190701');

INSERT INTO schema_migrations (version) VALUES ('20120203220932');

INSERT INTO schema_migrations (version) VALUES ('20120208231253');

INSERT INTO schema_migrations (version) VALUES ('20120301143226');

INSERT INTO schema_migrations (version) VALUES ('20120322223517');

INSERT INTO schema_migrations (version) VALUES ('20120328025842');

INSERT INTO schema_migrations (version) VALUES ('20120330103021');

INSERT INTO schema_migrations (version) VALUES ('20120330144057');

INSERT INTO schema_migrations (version) VALUES ('20120405170105');

INSERT INTO schema_migrations (version) VALUES ('20120414005431');

INSERT INTO schema_migrations (version) VALUES ('20120420185823');

INSERT INTO schema_migrations (version) VALUES ('20120422072257');

INSERT INTO schema_migrations (version) VALUES ('20120427152648');

INSERT INTO schema_migrations (version) VALUES ('20120506053156');

INSERT INTO schema_migrations (version) VALUES ('20120510184853');

INSERT INTO schema_migrations (version) VALUES ('20120517014034');

INSERT INTO schema_migrations (version) VALUES ('20120519015723');

INSERT INTO schema_migrations (version) VALUES ('20120521191429');

INSERT INTO schema_migrations (version) VALUES ('20120803143552');

INSERT INTO schema_migrations (version) VALUES ('20120906162503');

INSERT INTO schema_migrations (version) VALUES ('20120909053122');

INSERT INTO schema_migrations (version) VALUES ('20130207231310');

INSERT INTO schema_migrations (version) VALUES ('20130404211624');

INSERT INTO schema_migrations (version) VALUES ('20130429073928');

INSERT INTO schema_migrations (version) VALUES ('20130608171134');

INSERT INTO schema_migrations (version) VALUES ('20130613203350');

INSERT INTO schema_migrations (version) VALUES ('20130717104359');

INSERT INTO schema_migrations (version) VALUES ('20130801063213');

INSERT INTO schema_migrations (version) VALUES ('20131017093025');

INSERT INTO schema_migrations (version) VALUES ('20131213171804');

INSERT INTO schema_migrations (version) VALUES ('20140121132816');

INSERT INTO schema_migrations (version) VALUES ('20140214104217');

INSERT INTO schema_migrations (version) VALUES ('20140222162826');

INSERT INTO schema_migrations (version) VALUES ('20140308154022');

INSERT INTO schema_migrations (version) VALUES ('20140422134050');

INSERT INTO schema_migrations (version) VALUES ('20140422134627');

INSERT INTO schema_migrations (version) VALUES ('20140601102543');