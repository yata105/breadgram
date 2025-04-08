import { application } from "controllers/application"

import LikeController from "controllers/like_controller"
application.register("like", LikeController)
