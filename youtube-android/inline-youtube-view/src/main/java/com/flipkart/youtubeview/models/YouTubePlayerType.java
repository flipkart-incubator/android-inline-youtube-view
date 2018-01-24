/*
 * Apache License
 * Version 2.0, January 2004
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION
 *
 * Copyright (c) 2018 Flipkart Internet Pvt. Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of the
 * License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */
package com.flipkart.youtubeview.models;

import android.support.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({YouTubePlayerType.INVALID_VIEW, YouTubePlayerType.AUTO, YouTubePlayerType.STRICT_NATIVE, YouTubePlayerType.WEB_VIEW})
@Retention(RetentionPolicy.SOURCE)
public @interface YouTubePlayerType {
    /**
     * Invalid view
     */
    int INVALID_VIEW = 0;

    /**
     * Auto. If youtube service is available, it will render native player
     * else will fallback to WebView if web-url provided
     */
    int AUTO = 1;

    /**
     * render only native player
     */
    int STRICT_NATIVE = 2;

    /**
     * render only WebView player
     */
    int WEB_VIEW = 3;
}
