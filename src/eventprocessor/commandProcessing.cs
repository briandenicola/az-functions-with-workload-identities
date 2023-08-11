using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Azure.Messaging.EventHubs; 
using Microsoft.Extensions.Logging;

namespace Eventing
{
    public static class CommandProcessing
    {
        [FunctionName("CommandProcessing")]
        public static async Task Run(    
            [EventHubTrigger( "requests", ConsumerGroup =  "functions-client", Connection = "EVENTHUB_CONNECTION")]  EventData[] events,
            [Sql(commandText: "dbo.requests", connectionStringSetting: "SQL_CONNECTION")] IAsyncCollector<EventItem> EventItems,
            ILogger log)
        {
            foreach (EventData eventData in events)
            {
                log.LogInformation($"C# Event Hub trigger function processed a message: {eventData.EventBody}");

                var item = new EventItem();
                //item.Id = Guid.NewGuid();
                item.Message = eventData.EventBody.ToString();
                await EventItems.AddAsync(item);
            }
            await EventItems.FlushAsync();
        }
    }

    public class EventItem
    {
        public Guid Id { get; set; }
        public string Message { get; set; }
    }
}