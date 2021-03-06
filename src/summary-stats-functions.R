########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Fri Jul 16 17:08:16 2010
########################################################
#Analyze the death index files from the SSA/INEGI



bumpChart <- function(df, name, f = last.points, directlabel = FALSE, title = "", xlab = "", scale = "") {
    hom.count <- ddply(df, c("ANIODEF", name), nrow)
    hom.count <- ddply(hom.count, c("ANIODEF"), transform,
                        per = V1 / sum(V1))
    hom.count$ANIODEF <- as.factor(hom.count$ANIODEF)
    hom.count[[name]] <- as.factor(hom.count[[name]])
  
    
    expanded <- data.frame(LUGLEStxt =
                           rep(levels(hom.count[[name]]),
                               kmaxy - kminy + 1),
                           ANIODEF = rep(kminy:kmaxy,
                             each=length(levels(hom.count[[name]]))))
    names(expanded) <- c(name, "ANIODEF")
    hom.count  <- merge(hom.count,
                        expanded,
                        all.y = TRUE)
    hom.count[is.na(hom.count)] <- 0

    
    hom.count <- ddply(hom.count, c(name), transform,
                       order = per[ANIODEF == kmaxy])
    hom.count[[name]] <- reorder(hom.count[[name]], -hom.count$order)
    p <- ggplot(hom.count,
                aes_string(x = "ANIODEF",
                           y = "per",
                           group = name,
                           color = name)) +
        geom_line(size = 1) +
        scale_y_continuous(formatter = "percent") +
        opts(title = title) +
        ylab("percentage") +
        xlab(xlab) +
        scale_colour_hue(scale)

    if (directlabel == TRUE) {
        direct.label(p, f)

    } else {
        p
    }
}


dotPlot <- function(df, name, xlab = "", ylab = "", title = "") {
    df <- ddply(df, c(name), nrow)
    df[[name]] <- reorder(df[[name]], df$V1)
    ggplot(df, aes_string(y = name, x = "V1")) +
           geom_point() +
           xlab(xlab) +
           ylab(ylab) +
           opts(title = title) +
           xlab("number of homicides") 
}

########################################################
#Statistics Age, Sex, etc
########################################################

#Number of murders in 2006:last.year
totalHomicides <- function(df, title = ""){
  years <- kminy:last.year
  homicides <-  sapply(years,
                     function (x) nrow(subset(df, ANIODEF == x)))

  qplot(as.factor(years), homicides, geom = "line", group = 1) +
    scale_y_continuous(limits = c(0,max(homicides)), formatter = "comma") +
    xlab("year") +
    ylab("number of homicides") +
    opts(title = title)
}

########################################################
#Daily Homicides in Juarez
########################################################
formatDaily <- function(df){
    hom.count <- ddply(df, .(ANIODEF, MESDEF, DIADEF), nrow)
    hom.count$date <-  as.Date(paste(hom.count$ANIODEF,
                                     hom.count$MESDEF,
                                     hom.count$DIADEF,
                                     sep = "/"),
                                     "%Y/%m/%d")
    dates <- data.frame(date = seq(as.Date(str_c(kminy,"-01-01")),
                    as.Date(str_c(kmaxy,"-12-31")),
                    by="day"))
    hom.count <- merge(hom.count, dates, by= "date", all.y = TRUE)
    hom.count[is.na(hom.count)] <- 0
    hom.count
}

daily <- function(df, title = ""){
  df$year <- year(df$date)
  ggplot(df, aes(date, V1)) +
        scale_x_date(minor = "month", format = "%b") +
        geom_line(fill = "darkred") +
        opts(title = title) +
        ylab("number of homicides") +
        facet_wrap(~year, scale = "free_x", ncol = 1)
}

dayOfDeath <- function(df, year = kmaxy, title = ""){
    df <- subset(df, ANIODEF == year)
    days <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
    df$dayname <- format(df$date, "%A")
    df$dayname <- factor(df$dayname, levels = days)
    fit <- aov(V1~dayname, data = df[1:10,])
    print(summary(aov(fit)))
    ggplot(df, aes(dayname, V1)) +
        geom_boxplot(fill = "transparent", color = "red") +
        geom_jitter(fill = "darkred", alpha = .7) +
        ylab("number of homicides in a day") +
        xlab("day of week") +
#        scale_x_discrete(labels = days, breaks = days) +
        opts(title = title)
}


    #geom_vline(aes(xintercept = op.chi), alpha = .7) +
    #geom_text(aes(x,y, label = "Joint Operation Chihuahua"),
    #        data = data.frame(x = op.chi, y = 17),
    #        size = 4, hjust = 1.01, vjust = 0)

op.chi <- as.Date("2008-03-27")


########################################################
#Weekly homicides
########################################################
formatWeekly <- function(df) {
    #df$week <- format(df$date, "%Y %W")
    dates <- data.frame(date = seq(as.Date(str_c(kminy,"-01-01")),
                    as.Date(str_c(kmaxy,"-12-31")),
                    by="day"))
    df <- merge(df, dates, by= "date", all.y = TRUE)
    df[is.na(df)] <- 0
    df$week <- c(0, 0, 0 ,0, rep(1:c((nrow(df)) / 7), each = 7))[1:nrow(df)]
    hom.w <- ddply(df, .(week), function(df) sum(df$V1))
    hom.w <- subset(hom.w, week != 0 & week != max(hom.w$week))

    hom.w$date <- seq(as.Date(str_c(kminy, "-01-05")),
                    last.day,
                    by="week")[1:nrow(hom.w)]
    hom.w
}

formatWeekly <- function(df) {
    #df <- formatDaily(df)
    d <- wday(as.Date(str_c(kminy,"-01-01")))
    dates <- data.frame(date = seq(as.Date(str_c(kminy,"-01-01")),
                    as.Date(str_c(kmaxy,"-12-31")),
                    by="day"))
    df <- merge(df, dates, by= "date", all.y = TRUE)
    df[is.na(df)] <- 0
    df$week <- c(rep(0, d), rep(1:c((nrow(df)) / 7), each = 7))[1:nrow(df)]
    hom.w <- ddply(df, .(week), function(df) sum(df$V1))
    hom.w <- subset(hom.w, week != 0 & week != max(hom.w$week))

    hom.w$date <- seq(as.Date(str_c(kminy, "-01-05")),
                    as.Date(str_c(kmaxy,"-12-31")),
                    by="week")[1:nrow(hom.w)]
    hom.w
}

formatMonthly <- function(df) {
  df$month <- format(df$date, "%Y%m")
  hom.w <- ddply(df, .(month), function(df) sum(df$V1))

  hom.w$date <- seq(as.Date(str_c(kminy,"-01-15")),
                    last.day,
                    by="month")
    
  hom.w
}

weekly <- function(hom.count, title = ""){
    hom.w <- formatWeekly(hom.count)

    ggplot(hom.w, aes(date, V1)) +
        #geom_line(color = "darkred", sm.ize = 1.2) +
        geom_area(fill = "darkred") +
#        geom_line(color = "darkred", size = 1) +
        scale_x_date(minor = "month") +
    #geom_vline(aes(xintercept = op.chi), alpha = .7) +
    #geom_vline(aes(xintercept = op.mich), alpha = .7) +
        xlab("fecha") + ylab("número de homicidios") +
        opts(title = title)
    #geom_text(aes(x,y, label = "Joint Operation Chihuahua"),
    #        data = data.frame(x = op.chi, y = 55),
    #        size = 4, hjust = 1.01, vjust = 0) +
    #geom_text(aes(x,y, label = "Start of the Drug War"),
    #        data = data.frame(x = op.mich, y = 55),
    #        size = 4, hjust = 1.01, vjust = 0)
}

monthly <- function(hom.count, title = ""){
    hom.count$month <- format(hom.count$date, "%Y%m")
    hom.w <- ddply(hom.count, .(month), function(df) sum(df$V1))

    hom.w$date <- seq(as.Date(str_c(kminy,"-01-15")),
                    last.day,
                    by="month")

    ggplot(hom.w, aes(date, V1)) +
        geom_line(size = 1) +
        scale_x_date(minor = "month") +
        xlab("fecha") + ylab("número de homicidios") +
        opts(title = title) +
        ylim(0, max(hom.w$V1))
}


########################################################
#Age
########################################################
ageDensitySex <- function(df, title = "") {
    df <- subset(df, SEXOtxt %in% c("Males", "Females"))
    #df$SEXO <- car::recode(df$SEXO, "1 = 'Males'; 2 = 'Females'")
    ggplot(subset(df, EDADVALOR < 900),
           aes(EDADVALOR, group = SEXOtxt))+
        geom_density(aes(fill = SEXOtxt), alpha = .5) +
        xlab("age at death") +
        scale_fill_hue("Sex") +
        opts(title = title)
}

ageDensity <- function(df, title = "") {
  ggplot(subset(df, EDADVALOR < 900), aes(EDADVALOR)) +
    geom_density(fill = "darkred") +
        xlab("age at death") +
        opts(title = title)
}


ageDensityYear <- function(df, title = "") {
ggplot(subset(df, EDADVALOR < 900),
       aes(EDADVALOR, group = ANIODEF,
       fill = as.factor(ANIODEF))) +
    geom_density(alpha =.5) +
    scale_fill_brewer("Year") + #values = c("#FDC086",
                        #"#7FC97F", "purple"))+
    xlab("age at death") +
    opts(title = title) 
}


########################################################
#Age Percentage
########################################################

plotAgeBump <- function(df, age.groups, title = "") {
  homa <- subset(df, EDADVALOR < 900)
  homa$age.group <- cut(homa$EDADVALOR, age.groups)
  bumpChart(homa, "age.group", title = title, xlab = "year",
            scale = "age")
}

plotAgeDot <- function(df, age.groups, year, title = ""){
  hom.year <- subset(df, ANIODEF == year)
  homa.year <- subset(hom.year, EDADVALOR < 900)
  homa.year$age.group <- cut(homa.year$EDADVALOR, age.groups)
  dotPlot(homa.year, "age.group", title = title)
}


########################################################
#Hours when people are most likely to die
########################################################
plotHours <- function(df, year, fix = FALSE, title = "") {
  df <- subset(df, ANIODEF == year)
  hours <- count(subset(df, HORADEF < 24)$HORADEF)
  if(fix)
    hours[["freq"]][1] <- (hours[["freq"]][2] + hours[["freq"]][24]) / 2
  hours$x <- factor(hours$x, levels = c(6:23,0:5))

  ggplot(hours, aes(x, freq, group = 1)) +
    geom_line() +
    opts(title = title) +
    ylab("number of homicides") + xlab("time of day") +
    scale_x_discrete(breaks = c("6","12","18","0"),
                       labels = c("6:00 AM", "Noon", "6:00 PM",
                                  "Midnight"))
}


########################################################
#Percentage of Homicides with a Firearm
########################################################
completeDates <- function(df){
  dates <- data.frame(
               date = seq(as.Date(str_c(kminy, "01", "15", sep = "-")),
                          as.Date(str_c(kmaxy, "12", "15", sep = "-")),
                      by = "month"))
  merge(df, dates, all = TRUE)
}

plotFirearmPer <- function(df, title = "") {
  fir <- subset(df, CAUSADEF %in% c("X93", "X94", "X95"))
  totfir <- ddply(fir, .(ANIODEF, MESDEF), nrow)
  totfir <- subset(totfir, MESDEF != 0)
  totfir$date <- with(totfir,
                      as.Date(str_c(ANIODEF, MESDEF, "15", sep = "-")))
  tothom <- ddply(df, .(ANIODEF, MESDEF), nrow)
  tothom <- subset(tothom, MESDEF != 0)
  tothom$date <- with(tothom,
                      as.Date(str_c(ANIODEF, MESDEF, "15", sep = "-")))
  
  totfir <- completeDates(totfir)
  tothom <- completeDates(tothom)
  totfir$prop <- totfir$V1 / tothom$V1
  totfir$prop[is.na(totfir$prop)] <-  0
  ggplot(totfir, aes(date, prop, group = 1)) +
    geom_line() +
    scale_x_date(minor = "4 months") +
    geom_smooth() +
    scale_y_continuous(limits = c(0, max(totfir$prop)),
                       formatter = "percent") +
    opts(title = title) +
    ylab("percentage") + xlab("year")
}



#allages <-
 # data.frame(sapply(2006:2008, function(x) stats(subset(hom, ANIODEF == x & EDADVALOR < 900)$EDADVALOR)))

#summary(subset(hom.juarez, ANIODEF == 2007 & EDADVALOR < 900)$EDADVALOR)

#names(allages) <- 2006:2008
#rownames(allages) <- c("N", "mean", "Std.Dev.", "min", "Q1", "median",
#                      "Q3", "max", "missing values")


#apply(2006:2008, function(x) stats(subset(hom, ANIODEF == x & EDADVALOR < 900 & SEXO == "Males")$EDADVALOR))
#apply(2006:2008, function(x) stats(subset(hom, ANIODEF == x & EDADVALOR < 900 & SEXO == "Females")$EDADVALOR))


doctorPlot <- function(df, name, title = "", scale = "") {
  df <- ddply(df, c("ANIODEF", "MESDEF", name), nrow)
  df <- subset(df, MESDEF != 0)
#df <- ddply(hom.tj, .(ANIODEF, MESDEF, NECROPCIA), nrow)
  df$date <- as.Date(str_c(df$ANIODEF, df$MESDEF, "15", sep = "-"))
  dateseq <- seq(as.Date(str_c(kminy, "-01-15")),
                 as.Date(str_c(kmaxy, "-12-15")),
                 by = "months")
  levels <- levels(as.factor(df[[name]]))
  complete <- data.frame(date = rep(dateseq, each = length(levels)),
                         name = levels)
  df <- merge(df, complete,
              all.y = TRUE,
              by.x = c("date", name), by.y = c("date", "name"))
  df[is.na(df)] <- 0
  df <- ddply(df, c(name), transform, order = V1[length(V1)])
  df[[name]] <- reorder(df[[name]], -df$order)
  ggplot(df, aes_string(x = "date", y = "V1", group = name, color = name)) +
    geom_line(size = 1) +
    opts(title = title) +
    ylab("número de homicidios") +
    #scale_color_hue(scale) +
    scale_x_date(minor = "4 months") +
    xlab("fecha") +
    scale_colour_brewer(scale, palette = "Set1")
}
