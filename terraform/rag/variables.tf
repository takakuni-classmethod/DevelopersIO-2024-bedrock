variable "knowledge_bases" {
  type = object({
    /*
    If you don't know the model ID, you can list the available models using the following command:
    aws bedrock list-foundation-models --no-cli-pager \
    --query 'modelSummaries[*].{ModelName:modelName, ModelID:modelId, Input01:inputModalities[0],Input02:inputModalities[1],Input03:inputModalities[2], Output01:outputModalities[0]}' \
    --output table
    */
    embeddings_model_id         = string
    embeddings_model_dimensions = number
  })
  default = {
    embeddings_model_id         = "amazon.titan-embed-text-v1"
    embeddings_model_dimensions = 1536
  }
  description = "The database configuration for the Knowledge bases for Amazon Bedrock"
}
