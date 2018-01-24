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

import android.support.annotation.StringDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@SuppressWarnings("WeakerAccess")
public class PlayerStateList {
    public static final String NOT_STARTED = "NOT_STARTED";
    public static final String ENDED = "ENDED";
    public static final String PLAYING = "PLAYING";
    public static final String PAUSED = "PAUSED";
    public static final String BUFFERING = "BUFFERING";
    public static final String CUED = "CUED";
    public static final String NONE = "NONE";
    public static final String STOPPED = "STOPPED";

    @StringDef({NOT_STARTED, ENDED, PLAYING, PAUSED, BUFFERING, CUED, NONE, STOPPED})
    @Retention(RetentionPolicy.SOURCE)
    public @interface PlayerState {
    }
}