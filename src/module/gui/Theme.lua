local C = { -- Colors
    D ={ -- Dark Theme
        Black18 = Color3.fromRGB(18,18,18),
        Black24 = Color3.fromRGB(24,24,24),
        Black35 = Color3.fromRGB(35,35,35),
        Gray70 = Color3.fromRGB(70,70,70),
        Gray60 = Color3.fromRGB(60,60,60),
        Gray45 = Color3.fromRGB(45,45,45),
        Red150 = Color3.fromRGB(150,0,0),
        Red180 = Color3.fromRGB(180,0,0),
        Red210 = Color3.fromRGB(210,0,0),
        DarkGreen = Color3.fromRGB(0, 85, 0)
    },
    L = { -- Light Theme

    },
    Black = Color3.new(0,0,0),
    Red = Color3.new(1,0,0),
    Green = Color3.new(0,1,0),
    Orange = Color3.fromRGB(255, 85, 0),
    White = Color3.fromRGB(255,255,255),

}

-- The Gui names were designed so that they didnt overlap with properties names, this way I can keep the amount of nesting to a minimum
local Themes = { 
    Dark = {
        Background = {
            BackgroundColor3 = C.D.Black18,
            ImageColor3 = C.D.Black24,
            Content = {
                ScrollBarImageColor3 = C.D.Red150,
                VerticalList = {
                    Controls = {
                        Previous = {
                            BackgroundColor3 = C.D.Red180,
                            TextColor3 = C.White
                        },
                        Start = {
                            BackgroundColor3 = C.D.Red180,
                            TextColor3 = C.White
                        },
                        Next = {
                            BackgroundColor3 = C.D.Red180,
                            TextColor3 = C.White
                        }
                    }
                }
            },
            Header = {
                BackgroundColor3 = C.D.Gray60,
                Head = {
                    Icon = {
                        ImageColor3 = C.D.Red210
                    },
                    Title = {
                        TextColor3 = C.White
                    }
                },
                Window = {
                    Close = {
                        ImageColor3 = C.White
                    },
                    Maximize = {
                        ImageColor3 = C.White
                    },
                    Minimize = {
                        ImageColor3 = C.White
                    },
                }
            },
            StatusLbl = {
                TextColor3 = C.White
            },
            Version = {
                TextColor3 = C.White
            }
        },
        Minimized = {
            BackgroundColor3 = C.D.Black18,
            ImageColor3 = C.D.Black24,
            Window = {
                Close = {
                    ImageColor3 = C.White
                },
                Minimize = {
                    ImageColor3 = C.White
                },
            }
        },
        EmptyPane = {
            Subtext = {
                TextColor3 = C.White
            }
        },
        Pane = {
            Info = {
                Selector = {
                   InfoTitle = {
                       TextColor3 = C.White
                   },
                   Toggle = {
                        BackgroundColor3 = C.D.Gray60,
                        UIStroke = {
                            Color = C.White
                        }
                   } 
                },
                Table = {
                    BackgroundColor3 = C.D.Gray70,
                    BorderColor3 = C.White
                }
            },
            Bars = {
                SubTotalProgress = {
                    base = {
                        BackgroundColor3 = C.D.Gray45,
                        Clipper = {
                            Top = {
                                BackgroundColor3 = C.D.DarkGreen
                            }
                        },
                        SubTotal = {
                            TextColor3 = C.White
                        },
                        parts = {
                            TextColor3 = C.White
                        }
                    }
                }
            }
        },
        Stats = {
            Header = {
                BackgroundColor3 = C.D.Gray60,
                Arrow = {
                    TextColor3 = C.White
                },
                Title = {
                    TextColor3 = C.White
                }
            }
        },
        Table = {
            Body = {
                ScrollBarImageColor3 = C.D.Red150
            }
        },
        Column = {
            Primary = C.Black,
            Secondary = C.D.Black35,
            TextColor3 = C.White,
            Border = Color3.fromRGB(50, 56, 62)
        },
        Cell = {
            BackgroundColor3 = Color3.fromRGB(88, 88, 88),
            BorderColor3 = C.White,
            TextColor3 = C.White
        },
        ToggleButtons = {
            Default = {
               BackgroundColor3 = C.D.Gray60,
                TextColor3 = C.White,
                TextYAlignment = Enum.TextYAlignment.Center,
                Text = "<b>$</b>"
            },
            Active = {
                BackgroundColor3 = C.D.Red210,
                TextColor3 = C.White,
                Text = "<b><u>$</u></b>",
                TextYAlignment = Enum.TextYAlignment.Top
            }
        },
        StatusColors = {
            Normal = C.White,
            Warn = C.Orangee,
            Error = C.Red,
            Success = C.Green
        },
    }
}

return {
    Colors = C,
    Themes = Themes
}