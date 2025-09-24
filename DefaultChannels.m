function Out = DefaultChannels(channelPreset)
    switch channelPreset
        case 'LABS'
            Out.Slope = 0.000345;
            Out.Width = 0.61;
            Out.Height = 0.538;
            Out.Length = 13.72;
            Out.Sideslope = 0;
        case 'LABM'
            Out.Slope = 0.000200;
            Out.Width = 0.61;
            Out.Height = 0.762;
            Out.Length = 19.91;
            Out.Sideslope = 0;
        case 'LABL'
            Out.Slope = 0.000200;
            Out.Width = 0.61;
            Out.Height = 0.759;
            Out.Length = 19.91;
            Out.Sideslope = 0;
        case 'WELL'
            Out.Slope = 0.000200;
            Out.Width = 8;
            Out.Height = 1.40;
            Out.Length = 20.00;
            Out.Sideslope = 0;
    end
end