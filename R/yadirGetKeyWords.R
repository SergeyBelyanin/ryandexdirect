yadirGetKeyWords <- function(CampaignIds, 
                             AdGroupIds = NA, 
                             Ids = NA, 
                             States = c("OFF","ON","SUSPENDED"), 
                             WithStats = T,
                             Login,
                             Token){
  
  if(is.null(Login)|is.null(Token)) {
    stop("You must enter login and API token!")
  }
  
  #��������� ����� ������ ������
  start_time  <- Sys.time()
  
  #�������������� ���� �����
  result      <- data.frame(Id                            = integer(0), 
                            Keyword                       = character(0),
                            AdGroupId                     = integer(0),
                            CampaignId                    = integer(0),
                            ServingStatus                 = character(0),
                            State                         = character(0),
                            Status                        = character(0),
                            StrategyPriority              = character(0), 
                            StatisticsSearchImpressions   = integer(0),
                            StatisticsSearchClicks        = integer(0),
                            StatisticsNetworkImpressions       = integer(0),
                            StatisticsNetworkClicks       = integer(0),
                            UserParam1                    = character(0),
                            UserParam2                    = character(0),
                            Bid                           = integer(0),
                            ContextBid                    = integer(0))
  
  #��������� ������ �� ������� � json
  States          <- paste("\"",States,"\"",collapse=", ",sep="")
  
  #���������� ���������� �������� ������� ��������� ����������
  camp_num     <- as.integer(length(CampaignIds))
  camp_start   <- 1
  camp_step    <- 10
  
  packageStartupMessage("Processing", appendLF = F)
  #��������� ���� ��������� ��������
  while(camp_start <= camp_num){
    
    #���������� ����� �-�� �� ���� ����������
    camp_step   <-  if(camp_num - camp_start > 10) camp_step else camp_num - camp_start + 1
    
    #����������� ������ ��������� ��������
    Ids             <- ifelse(is.na(Ids), NA,paste0(Ids, collapse = ","))
    AdGroupIds      <- ifelse(is.na(AdGroupIds),NA,paste0(AdGroupIds, collapse = ","))
    CampaignIdsTmp  <- paste("\"",CampaignIds[camp_start:(camp_start + camp_step - 1)],"\"",collapse=", ",sep="")
    
    #����� ��������� offset
    lim <- 0
    
    while(lim != "stoped"){
      
      queryBody <- paste0("{
                          \"method\": \"get\",
                          \"params\": {
                          \"SelectionCriteria\": {
                          \"CampaignIds\": [",CampaignIdsTmp,"],
                          ",ifelse(is.na(Ids),"",paste0("\"Ids\": [",Ids,"],")),"        
                          ",ifelse(is.na(AdGroupIds),"",paste0("\"AdGroupIds\": [",AdGroupIds,"],")),"
                          \"States\": [",States,"]
    },
                          
                          \"FieldNames\": [
                              \"Id\",
                              \"CampaignId\",
                              \"AdGroupId\",
                              \"Keyword\",
                              \"UserParam1\",
                              \"UserParam2\",
                              \"Bid\",
                              \"ContextBid\",
                              \"StrategyPriority\",
                              \"Status\",
                              \"ServingStatus\",
                              \"State\",
                              \"Productivity\"
                              ",ifelse(WithStats == F, "",",\"StatisticsSearch\""),
                                ifelse(WithStats == F, "",",\"StatisticsNetwork\""),"],
                          \"Page\": {  
                              \"Limit\": 10000,
                              \"Offset\": ",lim,"}
    }
    }")

      answer <- POST("https://api.direct.yandex.com/json/v5/keywords", body = queryBody, add_headers(Authorization = paste0("Bearer ",Token), 'Accept-Language' = "ru",'Client-Login' = Login))
      stop_for_status(answer)
      dataRaw <- content(answer, "parsed", "application/json")
      
      #�������� �� ������ �� ������ ������
      if(length(dataRaw$error) > 0){
        stop(paste0(dataRaw$error$error_string, " - ", dataRaw$error$error_detail))
      }
      
      
      
      
      dataRaw$result$Keywords[[1]]$StatisticsSearch$Impressions
      #������ ������
      for(Keywords_i in 1:length(dataRaw$result$Keywords)){
        result      <- rbind(result,
                             data.frame(Id                            = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$Id), NA,dataRaw$result$Keywords[[Keywords_i]]$Id),
                                        Keyword                       = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$Keyword), NA,dataRaw$result$Keyword[[Keywords_i]]$Keyword),
                                        AdGroupId                     = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$AdGroupId), NA,dataRaw$result$Keywords[[Keywords_i]]$AdGroupId),
                                        CampaignId                    = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$CampaignId), NA,dataRaw$result$Keywords[[Keywords_i]]$CampaignId),
                                        ServingStatus                 = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$ServingStatus), NA,dataRaw$result$Keywords[[Keywords_i]]$ServingStatus),
                                        State                         = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$State), NA,dataRaw$result$Keywords[[Keywords_i]]$State),
                                        Status                        = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$Status), NA,dataRaw$result$Keywords[[Keywords_i]]$Status),
                                        StrategyPriority              = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$StrategyPriority), NA,dataRaw$result$Keywords[[Keywords_i]]$StrategyPriority), 
                                        StatisticsSearchImpressions   = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$StatisticsSearch$Impressions)|WithStats == F, NA,dataRaw$result$Keywords[[Keywords_i]]$StatisticsSearch$Impressions),
                                        StatisticsSearchClicks        = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$StatisticsSearch$Clicks)|WithStats == F, NA,dataRaw$result$Keywords[[Keywords_i]]$StatisticsSearch$Clicks),
                                        StatisticsNetworkImpressions  = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$StatisticsNetwork$Impressions)|WithStats == F, NA,dataRaw$result$Keywords[[Keywords_i]]$StatisticsNetwork$Impressions),
                                        StatisticsNetworkClicks       = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$StatisticsNetwork$Clicks|WithStats) == F, NA,dataRaw$result$Keywords[[Keywords_i]]$StatisticsNetwork$Clicks),
                                        UserParam1                    = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$UserParam1), NA,dataRaw$result$Keywords[[Keywords_i]]$UserParam1),
                                        UserParam2                    = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$UserParam2), NA,dataRaw$result$Keywords[[Keywords_i]]$UserParam2),
                                        Bid                           = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$Bid), NA,dataRaw$result$Keywords[[Keywords_i]]$Bid / 1000000),
                                        ContextBid                    = ifelse(is.null(dataRaw$result$Keywords[[Keywords_i]]$ContextBid), NA,dataRaw$result$Keywords[[Keywords_i]]$ContextBid / 1000000)))
      }
      #��������� �����, ��� ������� �������� ���
      packageStartupMessage(".", appendLF = F)
      #��������� �������� �� ��� ������ ������� ���� �������
      lim <- ifelse(is.null(dataRaw$result$LimitedBy), "stoped",dataRaw$result$LimitedBy + 1)
    }
    
    #���������� ��������� ��� ��������
    camp_start <- camp_start + camp_step
  }
  
  #��������� ����� ���������� ���������
  stop_time <- Sys.time()
  
  #��������� � ���, ��� �������� ������ ������ �������
  packageStartupMessage("Done", appendLF = T)
  packageStartupMessage(paste0("���������� ���������� �������� ����: ", nrow(result)), appendLF = T)
  packageStartupMessage(paste0("������������ ������: ", round(difftime(stop_time, start_time , units ="secs"),0), " ���."), appendLF = T)
  #���������� ���������
  return(result)}