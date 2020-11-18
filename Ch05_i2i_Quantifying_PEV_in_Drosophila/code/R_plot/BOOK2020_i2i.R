# Figure 5.5 of NEUBIAS 2020 Chapter 5
# 2020.11.17

### LOAD REQURIED PACKAGES ####################################################
library(ggplot2)    # load the ggplot library
library(ggbeeswarm) # load the ggbeeswarm library
library(gridExtra)  # load the gridExtra library
###############################################################################

### DEFINE THE THEME FOR THE PLOTS ############################################
fig.theme <- list(theme(plot.background = element_rect(fill = "white"),
                        panel.background = element_rect(fill = "white"),
                        panel.grid.major = element_line(color = "#BBBBBB"),
                        axis.ticks = element_blank(),
                        axis.title = element_text(color = "#444444",size=12),
                        axis.text = element_text(color = "#444444",size=12),
                        axis.text.x = element_blank(),
                        axis.line.y = element_line(color = "#BBBBBB"),
                        plot.title = element_text(color = "#444444",hjust = 0.5,size=14),
                        legend.position = "none"
                        ),
                   scale_color_manual(values=c("#0072B2","#E69F00")),      # colorblind-friendly
                   scale_y_continuous(sec.axis = sec_axis(trans=~.,labels=NULL)))
###############################################################################

### PANEL 1: LIKERT SCALE #####################################################
data.likert <- read.csv("Likert_BC.csv")
panel1 <- ggplot(data.likert, aes(Strain,LikertScale0to5,color=Strain)) +
  coord_cartesian(xlim = c(0.5,2.5),ylim = c(0,5), expand=FALSE, clip="off") + 
  geom_beeswarm(cex=2,size=2) +
  stat_summary(fun = "mean", color = "#D55E00", size = 6, geom = "point") +
  labs(x=NULL,y="Likert Scale (0-5)",title="Likert Scale (0-5)") +
  fig.theme
###############################################################################

### PANEL 2: DEVIATION FROM IDEAL RATIO #######################################
data.final.table <- read.csv("FinalTable.csv")
data.final.table$Strain <- c(rep("Mutant 1",20),rep("Mutant 2",20))
data.final.table[data.final.table == "NaN"] <- 0
panel2 <- ggplot(data = data.final.table, aes(Strain,Deviation.from.Ideal,color=Strain)) +
  geom_quasirandom(cex=2,width=0.25) +
  coord_cartesian(xlim = c(0.5,2.5),ylim = c(0,15.5), expand=FALSE, clip="off") + 
  stat_summary(fun = "mean", color = "#D55E00", size = 6, geom = "point") +
  labs(x=NULL,y="Deviation from Ideal Ratio",title="Deviation from Ideal Ratio") +
  fig.theme
###############################################################################

### PANEL 3: DEVIATION FROM RANDOM ORGANIZATION #######################################
panel3 <- ggplot(data = data.final.table, aes(Strain,Deviation.from.Random,color=Strain)) +
  geom_quasirandom(cex=2,width=0.25) +
  coord_cartesian(xlim = c(0.5,2.5),ylim = c(0,1.75), expand=FALSE, clip="off") + 
  stat_summary(fun = "mean", color = "#D55E00", size = 6, geom = "point") +
  labs(x=NULL,y="Deviation from Random Organization",title="Deviation from Random Organization") +
  fig.theme
###############################################################################

### PANEL 4: NUMBER OF PATCHES ################################################
panel4 <- ggplot(data = data.final.table, aes(Strain,Number.of.Patches,color=Strain)) +
  geom_quasirandom(cex=2,width=0.25) +
  coord_cartesian(xlim = c(0.5,2.5),ylim = c(0,50), expand=FALSE, clip="off") + 
  stat_summary(fun = "mean", color = "#D55E00", size = 6, geom = "point") +
  labs(x=NULL,y="Number of Patches",title="Number of Patches") +
  fig.theme
###############################################################################

### PANEL 5: AVERAGE SIZE #####################################################
panel5 <- ggplot(data = data.final.table, aes(Strain,Average.Size,color=Strain)) +
  geom_quasirandom(cex=2,width=0.25) +
  coord_cartesian(xlim = c(0.5,2.5),ylim = c(0,650), expand=FALSE, clip="off") + 
  stat_summary(fun = "mean", color = "#D55E00", size = 6, geom = "point") +
  labs(x=NULL,y=expression("Average Size (" * mu*m^2 * ")"),title=expression("Average Size (" * mu*m^2 * ")")) +
  fig.theme
###############################################################################

### PANEL 6: AVERAGE INTENSITY ################################################
panel6 <- ggplot(data = data.final.table, aes(Strain,Average.Intensity,color=Strain)) +
  geom_quasirandom(cex=2,width=0.25) +
  coord_cartesian(xlim = c(0.5,2.5),ylim = c(0,120), expand=FALSE, clip="off") + 
  stat_summary(fun = "mean", color = "#D55E00", size = 6, geom = "point") +
  labs(x=NULL,y="Average Intensity",title="Average Intensity") +
  fig.theme
###############################################################################

### PANEL 7: CROWDEDNESS ################################################
panel7 <- ggplot(data = data.final.table, aes(Strain,Crowdness,color=Strain)) +
  geom_quasirandom(cex=2,width=0.25) +
  coord_cartesian(xlim = c(0.5,2.5),ylim = c(0,15.5), expand=FALSE, clip="off") + 
  stat_summary(fun = "mean", color = "#D55E00", size = 6, geom = "point") +
  labs(x=NULL,y="Crowdedness (%)",title="Crowdedness (%)") +
  fig.theme
###############################################################################

### PANEL 8: DISTRIBUTION OF PATCH AREA #######################################
data.area.distribution <- read.csv("Area Distribution.csv")
data.area.mutant1 <- unlist(data.area.distribution[1:20,3:46])
data.area.mutant1 <- data.area.mutant1[data.area.mutant1 != 0]
data.area.mutant2 <- unlist(data.area.distribution[21:40,3:46])
data.area.mutant2 <- data.area.mutant2[data.area.mutant2 != 0]
data.areas <- data.frame(Patch.Area = c(data.area.mutant1,data.area.mutant2),
                         Strain = c(rep("Mutant 1",length(data.area.mutant1)),
                                    rep("Mutant 2",length(data.area.mutant2))))
data.areas.p1 <- sum(data.areas$Strain == "Mutant 1")/length(data.areas$Strain)
data.areas.p2 <- sum(data.areas$Strain == "Mutant 2")/length(data.areas$Strain)
panel8 <- ggplot(data = data.areas, aes(Patch.Area,color=Strain)) +
  geom_histogram(data = subset(data.areas,Strain=="Mutant 1"),aes(y=stat(density * data.areas.p1)),bins=20,fill="transparent") +
  geom_line(data = subset(data.areas,Strain=="Mutant 1"),aes(y=stat(density * data.areas.p1)), stat="density", bw=100) +
  geom_histogram(data = subset(data.areas,Strain=="Mutant 2"),aes(y=stat(density * data.areas.p2)),bins=20,fill="transparent") +
  geom_line(data = subset(data.areas,Strain=="Mutant 2"),aes(y=stat(density * data.areas.p2)), stat="density", bw=100) +
  labs(x=NULL,y="Density",
       title=expression("Distribution of Patch Area (" * mu*m^2 * ")")) +
  coord_cartesian(ylim = c(0,NA), expand=FALSE) + 
  fig.theme +
  theme(axis.text.x = element_text(color = "#444444",size=16))
###############################################################################

### PANEL 9: DISTRIBUTION OF PATCH INTENSITY ##################################
data.intensity.distribution <- read.csv("Intensity Distribution.csv")
data.intensity.mutant1 <- unlist(data.intensity.distribution[1:20,3:46])
data.intensity.mutant1 <- data.intensity.mutant1[data.intensity.mutant1 != 0]
data.intensity.mutant2 <- unlist(data.intensity.distribution[21:40,3:46])
data.intensity.mutant2 <- data.intensity.mutant2[data.intensity.mutant2 != 0]
data.intensities <- data.frame(Patch.Intensity = c(data.intensity.mutant1,data.intensity.mutant2),
                         Strain = c(rep("Mutant 1",length(data.intensity.mutant1)),
                                    rep("Mutant 2",length(data.intensity.mutant2))))
data.intensities.p1 <- sum(data.intensities$Strain == "Mutant 1")/length(data.intensities$Strain)
data.intensities.p2 <- sum(data.intensities$Strain == "Mutant 2")/length(data.intensities$Strain)
panel9 <- ggplot(data = data.intensities, aes(Patch.Intensity,color=Strain)) +
  geom_histogram(data = subset(data.intensities,Strain=="Mutant 1"),aes(y=stat(density * data.intensities.p1)),bins=20,fill="transparent") +
  geom_line(data = subset(data.intensities,Strain=="Mutant 1"),aes(y=stat(density * data.intensities.p1)), stat="density", bw=10) +
  geom_histogram(data = subset(data.intensities,Strain=="Mutant 2"),aes(y=stat(density * data.intensities.p2)),bins=20,fill="transparent") +
  geom_line(data = subset(data.intensities,Strain=="Mutant 2"),aes(y=stat(density * data.intensities.p2)), stat="density", bw=10) +
  labs(x=NULL,y="Density", title=expression("Distribution of Patch Intensity")) +
  coord_cartesian(xlim = c(0,149.999), ylim = c(0,NA), expand=FALSE) + 
  fig.theme +
  theme(axis.text.x = element_text(color = "#444444",size=16))
###############################################################################

### PLOT ALL PANELS AND EXPORT FIGURE #########################################
grid.arrange(panel1,panel2,panel3,
             panel4,panel5,panel6,
             panel7,panel8,panel9,ncol=3)
dev.copy(png, "FinalFigureR.png", width=1600, height=1280, 
         res=144, bg="transparent")
dev.off()
###############################################################################

  


