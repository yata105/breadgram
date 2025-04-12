import { application } from "controllers/application"

import FollowController from "controllers/follow_controller"
import LikeController from "controllers/like_controller"
import CommentController from "controllers/comment_controller"
import FeedFilterController from "controllers/feed_filter_controller"


application.register("feed-filter", FeedFilterController)
application.register("follow", FollowController)
application.register("like", LikeController)
application.register("comment", CommentController)