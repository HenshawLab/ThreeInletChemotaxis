options.BioReps = BioReps;
options.Reps = Reps;
options.particle_type = particle_type;
options.BackgroundImg = BackgroundImg;
options.accum_width = accum_width;
options.BinW = BinW;
options.PixSize = PixSize;
options.PixToMum = PixToMum;
options.FPS = FPS;
options.MainDir = MainDir;
options.OutputMainDir = OutputMainDir;
options.ExpName = ExpName;
options.WorkingDir = WorkingDir;
options.imgextension = imgextension;

save([OutputMainDir 'options.mat'],'options');