package trustNewsBooker;

import com.owlike.genson.annotation.JsonProperty;
import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;
import java.util.Objects;


@DataType()
public final class TrustNews {
	
	@Property()
	private final String id;
	
	@Property()
	private final String content;
	
	@Property()
	private final String signature;

	public String getId() {
		return id;
	}

	public String getContent() {
		return content;
	}

	public String getSignature() {
		return signature;
	}

	public TrustNews(@JsonProperty("id") final String id, 
					 @JsonProperty("content") final String content,
					 @JsonProperty("signature") final String signature) {
		this.id = id;
		this.content = content;
		this.signature = signature;
		}

	@Override 
	public boolean equals(final Object obj) { if (this == obj) { return
		  true; }
		  
		  if ((obj == null) || (getClass() != obj.getClass())) { return false; }
		  
		  TrustNews other = (TrustNews) obj;
		  
		  return Objects.deepEquals(new String[] {getId(), getContent(), getSignature()}, new String[] {
				  other.getId(), other.getContent(),other.getSignature()}); 
		  }
	  
	 @Override
	 public int hashCode() { 
			  return Objects.hash(getId(), getContent(),getSignature()); 
			 }
		 
	@Override
	public String toString() {
			return this.getClass().getSimpleName() + "@" + Integer.toHexString(hashCode()) + " [id=" + id + ", content=" + content
					+ ", signature=" + signature + "]";
		}


}
